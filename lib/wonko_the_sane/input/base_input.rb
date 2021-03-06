class BaseInput
  def logger
    Logging.logger[@artifact]
  end
end

class BaseSanitizer
  def self.sanitize(file)
    raise :AbstractMethodCallError
  end

  def self.sanitize(input, *sanitizers)
    output = [input]
    sanitizers.each do |sanitizer|
      tmp = []
      output.each do |file|
        #puts "Running #{sanitizer.to_s} on #{file.id}"
        result = sanitizer.sanitize(file.clone)
        if result.is_a? Array
          tmp = tmp + result
        elsif not result.nil?
          tmp << result
        end
      end
      output = tmp
    end
    return output
  end
end

class DownloadsFixer < BaseSanitizer
  def self.sanitize(file)
    file.client.downloads.map! do |download|
      if not download.size or not download.sha256 or download.sha256 == ''
        url = download.internalUrl ? download.internalUrl : download.url
        info = WonkoTheSane::Util::DeepStorageCache.get_info url, ctxt: file.uid
        download.size = info[:size]
        download.sha256 = info[:sha256]
        download
      end
      download
    end
    file.server.downloads.map! do |download|
      if not download.size or not download.sha256 or download.sha256 == ''
        url = download.internalUrl ? download.internalUrl : download.url
        info = WonkoTheSane::Util::DeepStorageCache.get_info url, ctxt: file.uid
        download.size = info[:size]
        download.sha256 = info[:sha256]
        download
      end
      download
    end
    file
  end
end
