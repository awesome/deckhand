module Deckhand
  class Configuration; end
end

require 'deckhand/configuration/dsl'
require 'singleton'

module Deckhand

  module ModelStorage; end

  def self.configure(&block)
    Configuration.instance.initializer_block = block
  end

  def self.config
    Configuration.instance
  end

  class Configuration
    include Singleton

    attr_accessor :initializer_block, :models_config, :global_config, :model_storage, :plugins
    attr_reader :models_by_name, :field_types

    def run
      self.models_config = {}
      self.global_config = OpenStruct.new(model_label: [:id])

      DSL.new(self).instance_eval &initializer_block

      names = models_config.keys.map {|m| [m.to_s, m] }.flatten
      @models_by_name = Hash[*names]

      setup_field_types if model_storage
    end

    delegate :field_type, :relation?, :relation_model_name, :to => :model_storage

    def reset
      self.models_config = self.global_config = nil
    end

    def for_model(model)
      models_config[model]
    end

    def has_model?(model)
      models_by_name.keys.include? model.to_s
    end

    def attachment?(model, name)
      # this is specific to Paperclip
      model.respond_to?(:attachment_definitions) and model.attachment_definitions.try(:include?, name)
    end

    private

    def setup_field_types
      @field_types = models_config.reduce({}) do |types, (model, config)|
        types[model.to_s] = config.fields_to_include.reduce({}) do |h, (name, options)|
          h[name] = field_type(model, name); h
        end
        types
      end
    end

  end

end