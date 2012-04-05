require "dropbox-api/client/raw"
require "dropbox-api/client/files"

module Dropbox
  module API

    class Client

      attr_accessor :raw, :connection

      def initialize(options = {})
        @connection = Dropbox::API::Connection.new(:token  => options.delete(:token),
                                                   :secret => options.delete(:secret))
        @raw        = Dropbox::API::Raw.new :connection => @connection
        @options    = options
      end

      include Dropbox::API::Client::Files

      def find(filename)
        ls(filename).first
      end

      def direct_url_for_path(path, options = {})
        response = raw.media({ :path => path }.merge(options))
        Dropbox::API::Object.init(response, self)
      end

      def share_url_for_path(path, options = {})
        response = raw.shares({ :path => path }.merge(options))
        Dropbox::API::Object.init(response, self)
      end
      
      def thumbnail_for_path(path, options = {})
        raw.thumbnails({ :path => path }.merge(options))
      end
      
      def ls(path = '')
        Dropbox::API::Dir.init({'path' => path}, self).ls
      end

      def account
        Dropbox::API::Object.init(self.raw.account, self)
      end

      def mkdir(path)
        # Remove the characters not allowed by Dropbox
        path = path.gsub(/[\\\:\?\*\<\>\"\|]+/, '')
        response = raw.create_folder :path => path
        Dropbox::API::Dir.init(response, self)
      end

      def search(term, options = {})
        options[:path] ||= ''
        results = raw.search({ :query => term }.merge(options))
        Dropbox::API::Object.convert(results, self)
      end

    end

  end
end
