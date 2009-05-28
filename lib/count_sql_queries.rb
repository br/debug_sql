module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter < AbstractAdapter
      private
      
      alias_method :select_query_counting, :select
      
      # Add the first non-ActiveRecord line number that invoked a database
      # call to the log. This is incredibly useful for debugging.
      def select(sql, name = nil)
        if @logger and @logger.level < Logger::INFO
          count = Thread.current[:sql_select_counter] || 0
          Thread.current[:sql_select_counter] = count + 1
        end

        select_query_counting(sql, name)
      end
    end
  end
end

module ActionController
  class Base
    def sql_select_counter
      if block_given?
        n = Thread.current[:sql_select_counter]
        yield
        Thread.current[:sql_select_counter] - n
      else
        Thread.current[:sql_select_counter]
      end
    end
  end
end

ActionController::Base.around_filter do |controller, action|
  Thread.current[:sql_select_counter] = 0
  action.call
  controller.logger.debug("#{Thread.current[:sql_select_counter]} SQL QUERIES: #{controller.request.request_uri}")
end
