module ActiveRecord
  module BulkUpdate
    module PostgreSQLAdapter # :nodoc:
      include ActiveRecord::BulkUpdate::BulkUpdateSupport

      def update_many(objects, options = {})
        objects.each_slice(options[:batch_size] || 10_000) do |batch_objects|
          tuples = tuples_with_values(batch_objects)
          sql = generate_sql_query(tuples)
          connection.update(sql, "#{self} Update")
        end
      end

      def update_statement
        # Generate update statement of query
        update_statement = ''
        # columns => [Array<ActiveRecord::ConnectionAdapters::PostgreSQLColumn>]
        # array of column object of table.
        # Column object contains information of the column like name, type, etc
        columns.each do |column|
          name = column.name
          # We need sql datatype of the column for typecasting. Rails datatypes
          # are unknown to postgresql
          type = column.sql_type
          # Skip the assignment for id and created_at as these field should not
          # be updated once the object is created
          next if %w[id created_at].include?(column.name)
          # e.g. "name = t.name::string, company_id = t.name::integer, "\
          #      "data = t.data::json"
          update_statement.concat("#{name} = t.#{name}::#{type}, ")
        end
        # Remove trailing ', ' at the end of string
        update_statement.chomp!(', ')
      end

      def tuples_with_values(batch_objects)
        # Generate tuples of values from activerecord objects
        # Final value of 'tuples' will look like:
        # "(1, 'name', 'data', 'TIMESTAMP'), (2, 'name', 'data', 'TIMESTAMP')"
        tuples = ''
        batch_objects.each do |object|
          tuple_values = values_for_tuple(object)
          # Append the tuple of values in the string
          tuples.concat("(#{tuple_values}), ")
        end
        tuples.chomp!(', ')
      end

      def vaules_for_tuple(object)
        # attributes_before_type_cast returns the exact values stored in db
        # i.e. If table contains enum field, DB stores Integer value, but
        # ActiveRecord::Base#attributes returns string value of ENUM.
        # ActiveRecord::Base#attributes_before_type_cast returns the exact
        # value stored in db (integer for enum)
        # The reason we need exact value is, we are generating SQL query,
        # which will attempt to update table entry directly.
        # The type mismatch of integer-string in case of Enum throws an
        # error.
        values = object.attributes_before_type_cast.values_at(*column_names)
        # Get the object values from attribute hash
        # E.g. '1', 'name', 'data', 'TIMESTAMP'
        tuple_values = ''
        values.each do |value|
          # Append NULL if attribute value is nil. Passing nil in #{}
          # converts it into '', which can throw type mismatch error
          # NULL is valid value for any type, but empty string is not
          if value.nil?
            tuple_values.concat('NULL, ')
          else
            tuple_values.concat("'#{value}', ")
          end
        end
        # Remove trailing ', ' at the end of string
        tuple_values.chomp!(', ')
      end

      def generate_sql_query(tuples)
        # Final query may look like:
        # UPDATE users SET
        # name = t.name::string, company_id = t.company_id::integer,
        # data = t.data::json
        # FROM (
        # values (1, 'name1', 1, { first: 'foo', last: 'bar' }, 'TIMESTAMP'),
        #        (2, 'name2', 2, { first: 'john', last: 'doe' }, 'TIMESTAMP')
        # ) AS t(id, name, company_id, data, updated_at)
        # WHERE users.id = t.id::integer
        "UPDATE #{table_name} SET "\
        "#{update_statement} "\
        "FROM ( values #{tuples} ) "\
        "AS t(#{column_names.join(', ')}) "\
        "WHERE #{table_name}.id = t.id::integer;"
      end
    end
  end
end
