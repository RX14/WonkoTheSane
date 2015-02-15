#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

Dir.chdir(File.dirname(__FILE__))

Dir['./*.rb'].each do |file| require_relative file end
Dir['./util/*.rb'].each do |file| require_relative file end
Dir['./input/*.rb'].each do |file| require_relative file end
Dir['./versionlists/*.rb'].each do |file| require_relative file end

$modLists = []
{
    'ironchests' => 'IronChests2',
    'biomesoplenty' => 'BiomesOPlenty',
    'codechicken.lib' => 'CodeChickenLib',
    'forgeessentials' => 'ForgeEssentials',
    'forgemultipart' => 'ForgeMultipart',
    'secretroomsmod' => 'SecretRoomsMod',
    'worldcore' => 'WorldCore',
    'compactsolars' => 'CompactSolars'
}.each do |artifact, urlId|
  $modLists << ForgeFilesModsList.new(artifact, urlId)
end
[
    {
        uid: 'ic2',
        url: 'http://jenkins.ic2.player.to',
        artifact: 'IC2_experimental'
    },
    {
        uid: 'dimdoors',
        url: 'http://build.technicpack.net',
        artifact: 'DimDoors'
    },
    {
        uid: 'enderore',
        url: 'http://build.technicpack.net',
        artifact: 'EnderOre'
    },
    {
        uid: 'flatbedrock',
        url: 'http://build.technicpack.net',
        artifact: 'FlatBedrock'
    },
    {
        uid: 'gregslighting',
        url: 'http://build.technicpack.net',
        artifact: 'GregsLighting'
    },
    {
        uid: 'hexxitgear',
        url: 'http://build.technicpack.net',
        artifact: 'HexxitGear'
    },
    {
        uid: 'inventorytweaks',
        url: 'http://build.technicpack.net',
        artifact: 'Inventory-Tweaks'
    },
    {
        uid: 'minefactoryreloaded',
        url: 'http://build.technicpack.net',
        artifact: 'MineFactoryReloaded'
    },
    {
        uid: 'modularpowersuits',
        url: 'http://build.technicpack.net',
        artifact: 'ModularPowersuits'
    },
    {
        uid: 'numina',
        url: 'http://build.technicpack.net',
        artifact: 'Numina'
    },
    {
        uid: 'buildcraft',
        url: 'http://nallar.me/buildservice',
        artifact: 'Buildcraft'
    },
    {
        uid: 'equivalentexchange3',
        url: 'http://nallar.me/buildservice',
        artifact: 'Equivalent%20Exchange%203'
    },
    {
        uid: 'openblocks',
        url: 'http://www.openmods.info:8080',
        artifact: 'OpenBlocks'
    },
    {
        uid: 'openeye',
        url: 'http://www.openmods.info:8080',
        artifact: 'OpenEye'
    },
    {
        uid: 'openmodslib',
        url: 'http://www.openmods.info:8080',
        artifact: 'OpenModsLib'
    },
    {
        uid: 'openperipheralsaddons',
        url: 'http://www.openmods.info:8080',
        artifact: 'OpenPeripheralAddons'
    },
    {
        uid: 'openperipheralscore',
        url: 'http://www.openmods.info:8080',
        artifact: 'OpenPeripheralCore'
    },
    {
        uid: 'openperipheralintegration',
        url: 'http://www.openmods.info:8080',
        artifact: 'OpenPeripheralIntegration'
    },
    {
        uid: 'logisticspipes',
        url: 'http://ci.thezorro266.com',
        artifact: 'LogisticsPipesMC1.2.5'
    },
    {
        uid: 'logisticspipes',
        url: 'http://ci.thezorro266.com',
        artifact: 'LogisticsPipesMC1.3.2'
    },
    {
        uid: 'logisticspipes',
        url: 'http://ci.thezorro266.com',
        artifact: 'LogisticsPipesMC1.4.7'
    },
    {
        uid: 'logisticspipes',
        url: 'http://ci.thezorro266.com',
        artifact: 'LogisticsPipesMC1.5.2'
    },
    {
        uid: 'logisticspipes',
        url: 'http://ci.thezorro266.com',
        artifact: 'LogisticsPipes1.7'
    },
    {
        uid: 'bdlib',
        url: 'http://jenkins.bdew.net',
        artifact: 'bdlib-1.7.10'
    },
    {
        uid: 'bdlib',
        url: 'http://jenkins.bdew.net',
        artifact: 'bdlib-1.7.10'
    },
    {
        uid: 'gendustry',
        url: 'http://jenkins.bdew.net',
        artifact: 'gendustry-1.7.10'
    },
    {
        uid: 'bdew.generators',
        url: 'http://jenkins.bdew.net',
        artifact: 'generators-1.7.10'
    },
    {
        uid: 'neiaddons',
        url: 'http://jenkins.bdew.net',
        artifact: 'neiaddons-1.7.10'
    },
    {
        uid: 'bdew.pressure',
        url: 'http://jenkins.bdew.net',
        artifact: 'pressure-1.7.10'
    }
].each do |obj|
  $modLists << JenkinsVersionList.new(obj[:uid], obj[:url], obj[:artifact])
end

$modLists.each do |list|
  #list.refresh
end

$vanilla = VanillaVersionList.new
$vanilla.refresh

$vanillaLegacy = VanillaLegacyVersionList.new
$vanillaLegacy.refresh

$liteloader = LiteLoaderVersionList.new
$liteloader.refresh

$forge = ForgeVersionList.new
$forge.refresh

$fml = FMLVersionList.new
$fml.refresh
