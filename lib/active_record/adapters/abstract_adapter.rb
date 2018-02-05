require 'active_record/bulk_update/abstract_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter # :nodoc:
      include ActiveRecord::BulkUpdate::AbstractAdapter
    end
  end
end
