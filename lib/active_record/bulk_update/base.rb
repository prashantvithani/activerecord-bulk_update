require 'bulk_update/version'

module ActiveRecord
  module BulkUpdate
    module BulkUpdateSupport # :nodoc:
      def supports_bulk_update?
        true
      end
    end
  end

  class Base # :nodoc:
    class << self
      def establish_connection_with_activerecord_bulk_update(*args)
        conn = establish_connection_without_activerecord_bulk_update(*args)
        ActiveRecord::BulkUpdate.load_from_connection_pool connection_pool
        conn
      end

      alias establish_connection_without_activerecord_bulk_update establish_connection
      alias establish_connection establish_connection_with_activerecord_bulk_update

      # Returns true if the current database connection adapter
      # supports bulk update functionality, otherwise returns false.
      def supports_bulk_update?(*args)
        connection.respond_to?(:supports_bulk_update?) &&
          connection.supports_bulk_update?(*args)
      end

      # @param objects [Array<ActiveRecord::Base>] array of objects to be
      #        updated
      # @param options [Hash] optional parameters
      # @option batch_size [Integer] number indicating the batch size of objects
      #                              to be updated in a single query
      # @option validate [Boolean] whether to run validation or not
      # @return nil
      def bulk_update(objects, options = {})
        timestamp_attributes_for_update = \
          send(:timestamp_attributes_for_update_in_model)

        objects.each do |object|
          # Get the field to store update timestamp
          update_key = object.class.instance_methods &
                       timestamp_attributes_for_update
          # Assign `Time.now` according to zone to `updated_at` for all objects
          object[update_key] = \
            default_timezone == :utc ? Time.now.utc : Time.now
          # Skip validation if 'validate: false' is specified in option
          options[:validate] = false || object.validate!
        end

        connection.update_many(objects, options)
      end
    end
  end
end
