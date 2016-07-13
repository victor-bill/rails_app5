unless Rails.env.test?
  Paperclip::Attachment.default_options.merge!({
                                                   path: ":rails_root/public:url",
                                                   url: "/system/:class/:attachment/:id_partition/:basename.:extension"})
else
  Paperclip::Attachment.default_options.merge!({
                                                   path: ":rails_root/public:url",
                                                   url: "/test/system/:class/:attachment/:id_partition/:basename.:extension"})
end

storage = YAML.load(ERB.new(File.read("#{Rails.root}/config/storage.yml")).result)[Rails.env]

if storage[:storage].to_s == "s3"
  Paperclip::Attachment.default_options.merge!(storage)
end