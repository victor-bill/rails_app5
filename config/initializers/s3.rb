CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => '',
      :aws_secret_access_key  => '',
      :region                 => ''
  }
  config.fog_directory  = ''
end
