require 'date'

task :default do
  system "rake --tasks"
end

namespace :archive do
  archive_path = "PlusMeDemo-#{Date.today}.xcarchive"
  ipa_path = "PlusMeDemo-#{Date.today}.ipa"

  task :archive do
    sh "xcodebuild archive -scheme PlusMeDemo -archivePath build/#{archive_path} | xcpretty -c"
  end

  task :export do
    sh "xcodebuild -exportArchive -exportOptionsPlist exportOptions.plist -archivePath build/#{archive_path} -exportPath build/ipa"
  end

  task :cleanup do
    sh "mv build/ipa/PlusMeDemo.ipa build/#{ipa_path}"
    sh "rm -r build/ipa"
  end
end

desc "Export IPA"
task :archive => ["archive:archive", "archive:export", "archive:cleanup"]
