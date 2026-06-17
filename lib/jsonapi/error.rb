module JSONAPI
  class Error
    attr_accessor :title, :detail, :id, :href, :code, :source, :links, :status, :meta

    # Rack 3.2 renamed some status symbols and dropped the old keys from
    # SYMBOL_TO_STATUS_CODE (e.g. :unprocessable_entity -> :unprocessable_content).
    # Map known legacy aliases so status resolution works across Rack versions.
    STATUS_SYMBOL_ALIASES = { unprocessable_entity: :unprocessable_content }.freeze

    def self.http_status_code(status_symbol)
      codes = Rack::Utils::SYMBOL_TO_STATUS_CODE
      return codes[status_symbol] if codes.key?(status_symbol)
      codes[STATUS_SYMBOL_ALIASES[status_symbol]]
    end

    def initialize(options = {})
      @title          = options[:title]
      @detail         = options[:detail]
      @id             = options[:id]
      @href           = options[:href]
      @code           = if JSONAPI.configuration.use_text_errors
                          TEXT_ERRORS[options[:code]]
                        else
                          options[:code]
                        end
      @source         = options[:source]
      @links          = options[:links]

      @status         = self.class.http_status_code(options[:status]).to_s
      @meta           = options[:meta]
    end

    def to_hash
      hash = {}
      instance_variables.each {|var| hash[var.to_s.delete('@')] = instance_variable_get(var) unless instance_variable_get(var).nil? }
      hash
    end
  end

  class Warning
    attr_accessor :title, :detail, :code
    def initialize(options = {})
      @title          = options[:title]
      @detail         = options[:detail]
      @code           = if JSONAPI.configuration.use_text_errors
                          TEXT_ERRORS[options[:code]]
                        else
                          options[:code]
                        end
    end

    def to_hash
      hash = {}
      instance_variables.each {|var| hash[var.to_s.delete('@')] = instance_variable_get(var) unless instance_variable_get(var).nil? }
      hash
    end
  end
end
