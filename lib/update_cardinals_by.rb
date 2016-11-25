require 'active_support/concern'

module UpdateCardinalsBy
  extend ActiveSupport::Concern

  # Changes given attributes by delta.
  # @param attributes, hash from attribute to delta
  # @param &block Block to execute after making update.
  #               Will receive indifferent hash from attribute to latest value in db.
  # @returns indifferent hash from attribute to latest value in db.
  def update_cardinals_by!(attributes, &block)
    db_attributes = attributes.map { |k, v| [self.class.connection.quote_column_name(k), v] }
    updates = db_attributes.map.with_index { |(k, v), i| "#{k} = #{k} + $#{i+1}" }
    binds = db_attributes.map { |k, v| [column_for_attribute(k), v] }

    transaction do
      res = self.class.connection.exec_query(
        "update #{self.class.table_name} " \
        "set #{updates.join(', ')} " \
        "where id = #{id} " \
        "returning #{db_attributes.map(&:first).join(', ')}",
        'SQL', binds
      ).first
       .map { |k, v| [k, column_for_attribute(k).type_cast_from_database(v)] }
      res = HashWithIndifferentAccess[ res ]

      yield res if block_given?

      res.each { |attr, v| raw_write_attribute attr, v }
    end
  end
end