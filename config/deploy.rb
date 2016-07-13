# config valid only for Capistrano 3.1
lock '3.5.0'

set :application, 'rails5_app'
set :repo_url, 'https://github.com/victor-bill/rails_app5.git'

ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :deploy_to, '/var/www/rails5_app'

set :pty, true

set :linked_files, %w{config/database.yml config/storage.yml}
set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :puma_threads,    [4, 16]
set :puma_workers,    0


set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"

set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end


namespace :deploy do
  # before :restart, :copy_nginx_configs
  # before :restart, :files_folder
  before :migrate, :create_db

  # before :starting, "monit:stop"
  # after :finishing, "monit:copy_configs"
  # after :finishing, "monit:start"

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      invoke 'puma:restart'
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

# task :copy_nginx_configs do
#   rails_env = fetch(:rails_env)
#   on roles(:app) do
#     execute "sudo cp #{release_path.join("config/deploy/configs/nginx/#{rails_env}/nginx.conf")} /etc/nginx/nginx.conf"
#     execute "sudo cp #{release_path.join("config/deploy/configs/nginx/#{rails_env}/bdr")} /etc/nginx/sites-available/bdr"
#     execute "sudo ln -s -f /etc/nginx/sites-available/bdr /etc/nginx/sites-enabled/bdr"
#   end
# end

# task :files_folder do
#   on roles(:app) do
#     execute "sudo mkdir -p /srv/files"
#     execute "sudo chmod 757 /srv/files"
#     execute "mkdir -p /srv/files/bdr/system"
#     execute "ln -s -f /srv/files/bdr/system #{release_path.join("public/system")}"
#   end
# end

task :create_db do
  on roles(:app) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, "db:create"
      end
    end
  end
end

desc "Upload file"
task :upload_file do
  on roles(:app) do
    upload!("vendor/import/next_2.csv", "#{current_path}/vendor/import/next_2.csv")
  end
end
