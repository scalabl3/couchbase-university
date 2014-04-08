require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'


# class HTMLWithPants < Redcarpet::Render::HTML
#   include Redcarpet::Render::SmartyPants
#   include Rouge::Plugins::Redcarpet
# end

module Rouge
  module Plugins
    module RedcarpetLines
      def block_code(code, language)
        #puts "language = #{language}"
        lexer = Lexer.find_fancy(language, code) || Lexers::PlainText

        # XXX HACK: Redcarpet strips hard tabs out of code blocks,
        # so we assume you're not using leading spaces that aren't tabs,
        # and just replace them here.
        if lexer.tag == 'make'
          code.gsub! /^    /, "\t"
        end

        formatter = Formatters::HTML.new(
          :css_class => "highlight #{lexer.tag}",
          :line_numbers => true
        )

        formatter.format(lexer.lex(code))
      end
      protected
        def rouge_formatter(opts={})
          Formatters::HTML.new(opts)
        end
    end
  end
  module Formatters
    class HTML < Formatter
      def stream_tableized(tokens)
        num_lines = 0
        last_val = ''
        formatted = ''

        tokens.each do |tok, val|
          last_val = val
          num_lines += val.scan(/\n/).size
          span(tok, val) { |str| formatted << str }
        end

        # add an extra line for non-newline-terminated strings
        if last_val[-1] != "\n"
          num_lines += 1
          span(Token::Tokens::Text::Whitespace, "\n") { |str| formatted << str }
        end

        # generate a string of newline-separated line numbers for the gutter
        #numbers = num_lines.times.map do |x|
        #  %<<div class="lineno">#{x+1}</div>>
        #end.join
        
        # use spans instead
        numbers = num_lines.times.map do |x|
          %<<span class="lineno">#{x+1}</span>\n>
        end.join
        
        #puts "[#{numbers}]"
        
        yield "<div class=#{@css_class.inspect}>" if @wrap
        yield '<table class="gutterlines" cellpadding="0" cellspacing="0" border="0"><tbody><tr>'

        # the "gl" class applies the style for Generic.Lineno
        yield "<td class=\"gutter gl\">#{numbers}</td>"
        yield "<td class=\"code\">#{formatted}</td>"

        yield '</tr></tbody></table>'
        yield '</div>' if @wrap
      end
    end
  end
end

class DOCHTML < Redcarpet::Render::HTML
  include Rouge::Plugins::RedcarpetLines # yep, that's it.
end
