# typed: strict
# frozen_string_literal: true

require "strscan"
require "erb"

module RubyLsp
  class ERBDocument < Document
    sig { override.returns(Prism::ParseResult) }
    def parse
      return @parse_result unless @needs_parsing

      @needs_parsing = false

      @parse_result = Prism.parse(scan(@source))
    end

    private

    sig { params(source: String).returns(String) }
    def scan(source)
      output = +""
      # There are three variations of Scanner: TrimScanner, ExplicitScanner,
      # SimpleScanner. Worth investigating how each are distinct
      scanner = ERB::Compiler::TrimScanner.new(source, "", false)
      scanner.scan do |token|
        output << if ["<%", "<%=", "<%-", "%>", "-%>"].include?(token)
          " " * token.length
        else
          token
        end
      end

      output
    end
  end
end
