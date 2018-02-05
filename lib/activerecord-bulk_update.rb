ActiveSupport.on_load(:active_record) do
  require "active_record/bulk_update/base"
end
