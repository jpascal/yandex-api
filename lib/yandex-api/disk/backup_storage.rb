require 'yandex-api'

module Yandex
  module API
    module Disk
      class BackupStorage < Backup::Storage::Base
        include Backup::Storage::Cycler

        class Error < Backup::Error; end

        attr_accessor :access_token
        attr_accessor :path
        attr_accessor :verbose

        def initialize(model, storage_id = nil, &block)
          super
          instance_eval(&block) if block_given?
          @path ||= 'app:/'
          @verbose ||= true
        end

        def connection
          unless @connection
            Disk.configuration = { 'token' => access_token, 'verbose' => verbose }
            @connection = Disk::Storage
          end
          @connection
        end

        def transfer!
          tmp = Pathname.new(@path)
          remote_path.scan(/\/([^\/]+)/).each do |dir|
            tmp = tmp.join(dir[0])
            connection.mkdir(tmp)
          end

          package.filenames.each do |filename|
            src = File.join(Backup::Config.tmp_path, filename)
            dest = File.join(remote_path, filename)
            Backup::Logger.info "Storing '#{ dest }'..."
            connection.write!(File.open(src), dest)
          end
        rescue => e
          ::Backup::Logger.error "Error: #{e.message}"
          raise
        end

        def remove!(package)
          Backup::Logger.info "Removing backup package dated #{ package.time }..."
          remote_path = remote_path_for(package)
          connection.rm!(remote_path)
        rescue => e
          return if e.message.empty?
          Backup::Storage::Base::Logger.warn "Error: #{e.message}"
          raise
        end

        def storage_name
          'Yandex::Disk'
        end
      end
    end
  end
end
