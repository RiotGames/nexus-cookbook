#
# Cookbook Name:: nexus
# Library:: chef_nexus
#
# Copyright 2011, DTO Solutions, Inc.
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
class Chef
  module Nexus
    DATABAG = "nexus"
    CREDENTIALS_DATABAG_ITEM = "credentials"
    LICENSE_DATABAG_ITEM = "license"
    CERTIFICATES_DATABAG_ITEM = "certificates"
    SSL_CERTIFICATE_DATABAG_ITEM = "ssl_certificate"
    SSL_CERTIFICATE_CRT = "crt"
    SSL_CERTIFICATE_KEY = "key"
    
    class << self
      def get_ssl_certificate_data_bag
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, SSL_CERTIFICATE_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(CREDENTIALS_DATABAG_ITEM)
        end
        data_bag_item
      end

      def get_ssl_certificate_crt(data_bag_item)
        require 'base64'
        Base64.decode64(data_bag_item[SSL_CERTIFICATE_CRT])
      end

      def get_ssl_certificate_key(data_bag_item)
        require 'base64'
        Base64.decode64(data_bag_item[SSL_CERTIFICATE_KEY])
      end

      def get_credentials_data_bag
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, CREDENTIALS_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(CREDENTIALS_DATABAG_ITEM)
        end
        validate_credentials_data_bag(data_bag_item)
        data_bag_item
      end

      def get_license_data_bag
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, LICENSE_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(LICENSE_DATABAG_ITEM)
        end
        validate_license_data_bag(data_bag_item)
        data_bag_item
      end

      def get_certificates_data_bag(node)
        begin
          data_bag_item = Chef::EncryptedDataBagItem.load(DATABAG, CERTIFICATES_DATABAG_ITEM)
        rescue Net::HTTPServerException => e
          raise Nexus::EncryptedDataBagNotFound.new(CERTIFICATES_DATABAG_ITEM)
        end
        validate_certificates_data_bag(data_bag_item, node)
        data_bag_item
      end

      def nexus(node)
        require 'nexus_cli'
        data_bag_item = get_credentials_data_bag
        default_credentials = data_bag_item["default_admin"]
        updated_credentials = data_bag_item["updated_admin"]
        overrides = {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository]}
        begin
          NexusCli::Factory.create(overrides.merge default_credentials)
        rescue NexusCli::PermissionsException, RestClient::Unauthorized => e
          NexusCli::Factory.create(overrides.merge updated_credentials)
        end
      end

      def check_old_credentials(username, password, node)
        require 'nexus_cli'
        overrides = {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository], "username" => username, "password" => password}
        begin
          nexus = NexusCli::Factory.create(overrides)
          true
        rescue NexusCli::PermissionsException, RestClient::Unauthorized => e
          false
        end
      end

      private

        def validate_credentials_data_bag(data_bag_item)
          raise Nexus::InvalidDataBagItem.new(CREDENTIALS_DATABAG_ITEM, "default_admin") unless data_bag_item["default_admin"]
          raise Nexus::InvalidDataBagItem.new(CREDENTIALS_DATABAG_ITEM, "updated_admin") unless data_bag_item["updated_admin"]
        end

        def validate_license_data_bag(data_bag_item)
          raise Nexus::InvalidDataBagItem.new(LICENSE_DATABAG_ITEM, "file") unless data_bag_item["file"]
        end

        def validate_certificates_data_bag(data_bag_item, node)
          node[:nexus][:smart_proxy][:trusted_servers].each do |server|
            raise Nexus::InvalidDataBagItem.new(CERTIFICATES_DATABAG_ITEM, server) unless data_bag_item[server]
            raise Nexus::InvalidDataBagItem.new(CERTIFICATES_DATABAG_ITEM, "#{server}::certificate") unless data_bag_item[server]["certificate"]
            raise Nexus::InvalidDataBagItem.new(CERTIFICATES_DATABAG_ITEM, "#{server}::description") unless data_bag_item[server]["description"]
          end
        end
    end
  end
end