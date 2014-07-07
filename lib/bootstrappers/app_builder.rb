module Bootstrappers
  class AppBuilder < Rails::AppBuilder

    include Bootstrappers::Actions
    include Bootstrappers::LayoutActions


    def raise_delivery_errors
      replace_in_file 'config/environments/development.rb', 'raise_delivery_errors = false', 'raise_delivery_errors = true'
    end

    def add_common_rake_tasks
      directory 'tasks', 'lib/tasks'
    end

    def add_devise_gem
      inject_into_file 'Gemfile', "\ngem 'devise', '3.2.4'",
      :after => /gem 'jquery-rails'/
    end

    def add_rvmrc_and_powrc
      template "rc/.rvmrc", '.rvmrc', :force => true
      template "rc/.powrc", '.powrc', :force => true
    end

    def create_capistrano_files
      template 'capistrano/deploy_rb.erb', 'config/deploy.rb',:force => true
      template 'capistrano/Capfile', 'Capfile',:force => true
      empty_directory 'config/deploy'
      directory 'capistrano/deploy', 'config/deploy'
    end

    def create_database
      bundle_command 'exec rake db:create'
    end

    def generate_devise
      generate 'devise:install'
      generate 'devise User'
    end

    def generate_auto_facebook
      generate 'auto_facebook:user'
      generate 'auto_facebook:install'
    end

    def insert_admin_method_to_user
      inject_into_file 'app/models/user.rb',
        "\n\n  def admin?\n    Setting.admin_emails.include?(email)\n  end\n", :after => '# attr_accessible :title, :body'
    end

    def replace_email_sender_for_devise
      replace_in_file 'config/initializers/devise.rb', /config\.mailer_sender = \'.+\'/ , "config.mailer_sender = Setting.email_sender"
    end

    def gitignore_files
      concat_file 'bootstrappers_gitignore', '.gitignore'
      ['app/models',
       'app/assets/images',
       'app/views/pages',
       'db/migrate',
       'log',
      ].each do |dir|
        empty_directory_with_keep_file dir
      end
    end

    def init_git
      run "git init"
    end


    def build_settings_from_config

      template 'setting.rb', 'app/models/setting.rb',:force => true
      template 'config_yml.erb', 'config/config.yml',:force => true
      template 'config_yml.erb', 'config/config.yml.example',:force => true
    end

    def create_initializers
      directory 'initializers', 'config/initializers'
    end

    def add_common_method_to_application_controller
      template 'application_controller_rb', 'app/controllers/application_controller.rb',:force => true
    end


    def remove_routes_comment_lines
      replace_in_file 'config/routes.rb', /Rails\.application\.routes\.draw do.*end/m, "Rails.application.routes.draw do\nend"
    end

    def use_mysql_config_template
      template 'mysql_database.yml.erb', 'config/database.yml.example', :force => true
    end


  end
end
