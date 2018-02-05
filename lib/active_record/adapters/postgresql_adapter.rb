require 'active_record/connection_adapters/postgresql_adapter'
require 'active_record/bulk_update/adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      include ActiveRecord::BulkUpdate::PostgreSQLAdapter
    end
  end
end
