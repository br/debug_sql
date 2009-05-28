module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter < AbstractAdapter
      private
        alias_method :select_without_line_number_logging, :select
        
        # Add the first non-ActiveRecord line number that invoked a database
        # call to the log. This is incredibly useful for debugging.
        def select(sql, name = nil)
          if @logger and @logger.level < Logger::INFO
            begin
              raise
            rescue => e
              matcher = /\/vendor\//
              in_vendor_code = false
              e.backtrace.each do |line|
                if matcher.match(line)
                  in_vendor_code = true
                elsif in_vendor_code
                  @logger.debug("SQL Load from #{line}")
                  break
                end
              end
            end
          end

          select_without_line_number_logging(sql, name)
        end
    end
  end
end
