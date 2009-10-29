module Fog
  module AWS
    class EC2

      def security_groups
        Fog::AWS::EC2::SecurityGroups.new(:connection => self)
      end

      class SecurityGroups < Fog::Collection

        attribute :group_name

        def initialize(attributes)
          @group_name ||= []
          super
        end

        def all(group_name = [])
          data = connection.describe_security_groups(group_name).body
          security_groups = Fog::AWS::EC2::SecurityGroups.new({
            :connection => connection,
            :group_name => group_name
          }.merge!(attributes))
          data['securityGroupInfo'].each do |security_group|
            security_groups << Fog::AWS::EC2::SecurityGroup.new({
              :collection => security_groups,
              :connection => connection
            }.merge!(security_group))
          end
          security_groups
        end

        def create(attributes = {})
          security_group = new(attributes)
          security_group.save
          security_group
        end

        def get(group_name)
          if group_name
            all(group_name).first
          end
        rescue Fog::Errors::BadRequest
          nil
        end

        def new(attributes = {})
          Fog::AWS::EC2::SecurityGroup.new(
            attributes.merge!(
              :collection => self,
              :connection => connection
            )
          )
        end

        def reload
          self.clear.concat(all(group_name))
        end

      end

    end
  end
end
