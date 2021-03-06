class ForgeInstallerProfileInput < BaseInput
  def initialize(artifact)
    @artifact = artifact
  end

  def parse(data, version)
    object = JSON.parse data, symbolize_names: true
    info = object[:versionInfo]
    file = WonkoVersion.new

    file.uid = @artifact
    file.version = version
    file.time = info[:time]
    file.type = info[:type]
    file.client.mainClass = info[:mainClass]
    file.client.minecraftArguments = info[:minecraftArguments]
    file.client.assets = info[:assets]
    file.requires << Referenced.new('net.minecraft', object[:install][:minecraft])
    libraries = info[:libraries].map do |obj|
      MojangInput.sanetize_mojang_library obj
    end.flatten 1
    file.client.downloads = libraries
    file.common.folders['minecraft/mods'] = ['mc.forgemods']
    file.common.folders['minecraft/mods'] << 'mc.forgecoremods' if object[:install][:minecraft].match /[^1]*1\.[0-6]/
    file.common.folders['minecraft/coremods'] = ['mc.forgecoremods'] if object[:install][:minecraft].match /[^1]*1\.[0-6]/
    file.server.downloads = libraries
    file.server.launchMethod = 'java.mainClass'
    file.server.extra[:forgeLibraryName] = %W(net.minecraftforge:forge:#{object[:install][:minecraft]}-#{version}:universal net.minecraftforge:forge:#{object[:install][:minecraft]}-#{version} net.minecraftforge:forge:#{version}:universal net.minecraftforge:forge:#{version} net.minecraftforge:minecraftforge:#{object[:install][:minecraft]}-#{version}:universal net.minecraftforge:minecraftforge:#{object[:install][:minecraft]}-#{version} net.minecraftforge:minecraftforge:#{version}:universal net.minecraftforge:minecraftforge:#{version})

    return BaseSanitizer.sanitize file, MojangExtractTweakersSanitizer, MojangSplitLWJGLSanitizer, ForgeRemoveMinecraftSanitizer, ForgeFixJarSanitizer, ForgePackXZUrlsSanitizer, ForgeServerMainClassSanitizer
  end
end

class ForgeFixJarSanitizer < BaseSanitizer
  def self.sanitize(file)
    file.client.downloads.map! do |lib|
      ident = WonkoTheSane::Util::MavenIdentifier.new(lib.name)
      ident.artifact = 'forge' if 'net.minecraftforge' == ident.group && 'minecraftforge' == ident.artifact
      if ['forge', 'fml'].include?(ident.artifact) && ['net.minecraftforge', 'cpw.mods'].include?(ident.group)
        mcversion = nil
        file.requires.each do |req|
          if req.uid == 'net.minecraft'
            mcversion = req.version
          end
        end
        lib = lib.clone
        ident.classifier = 'universal'
        ident.version = "#{mcversion}-#{ident.version}" unless ident.version.start_with? "#{mcversion}"
        lib.name = ident.to_name()
      end
      lib
    end
    file
  end
end

# Removes minecraft stuff (libraries, arguments etc.)
class ForgeRemoveMinecraftSanitizer < BaseSanitizer
  def self.sanitize(file)
    return nil if file.uid == 'org.lwjgl' # remove lwjgl, it's managed by minecraft
    return file if file.uid != 'net.minecraftforge'
    mcversion = nil
    file.requires.each do |req|
      if req.uid == 'net.minecraft'
        mcversion = req.version
      end
    end
    minecraft = Registry.instance.retrieve 'net.minecraft', mcversion
    if not minecraft
      # if we can't find the wanted version on the first try we try reloading the list to see if we get something
      WonkoTheSane.lists.each do |list|
        list.refresh if list.artifact == 'net.minecraft'
      end
      minecraft = Registry.instance.retrieve 'net.minecraft', mcversion
    end
    if minecraft
      file.client.mainClass = nil if minecraft.client.mainClass == file.client.mainClass
      file.client.minecraftArguments = nil if minecraft.client.minecraftArguments == file.client.minecraftArguments
      file.client.assets = nil if minecraft.client.assets == file.client.assets
      file.client.downloads.select! do |lib|
        nil == minecraft.client.downloads.find do |mcLib|
          lib.name == mcLib.name
        end
      end
      file.requires.select! do |req|
        if minecraft.requires
          nil == minecraft.requires.find do |mcReq|
            req == mcReq
          end
        else
          true
        end
      end
    else
      # don't know which version of minecraft this is, so we can't know which parts to eliminate
    end
    file
  end
end

class ForgePackXZUrlsSanitizer < BaseSanitizer
  @@packXZLibs = ['org.scala-lang', 'com.typesafe', 'com.typesafe.akka']

  def self.sanitize(file)
    file.client.downloads.map! do |lib|
      if @@packXZLibs.include? WonkoTheSane::Util::MavenIdentifier.new(lib.name).group
        lib = lib.clone
        lib.mavenBaseUrl = 'http://repo.spongepowered.org/maven/'
      end
      lib
    end
    file
  end
end

class ForgeServerMainClassSanitizer < BaseSanitizer
  def self.sanitize(file)
    file.server.downloads.each do |download|
      if file.server.extra[:forgeLibraryName].include? download.name
        url = download.internalUrl ? download.internalUrl : download.url
        libFile = HTTPCache.file(url, ctxt: file.uid, check_stale: false)
        # Handle entries one by one
        text = ExtractionCache.get(libFile, :zip, 'META-INF/MANIFEST.MF')
        lines = text.lines
        lines.each do |l|
          if l =~ /Main-Class: (.*)/
            file.server.mainClass = $1.strip
          end
        end
      end
    end
    file
  end
end
