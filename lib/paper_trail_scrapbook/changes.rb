module PaperTrailScrapbook
  class Changes

    include Concord.new(:version)

    def initialize(*)
      super

      build_associations
    end

    BULLET = '•'

    def change_log
      changes.map{ |k,v| digest(k,v)}.join("\n")
    end

    private

    def digest(k,v)
      old, new = v
      "#{BULLET} #{k}: " + if old.nil?
                             find_value(k,new)
                           else
                             "#{find_value(k,old)} -> #{find_value(k,new)}"
                           end
    end

    def find_value(key, value)
      return value unless assoc.key?(key)

      assoc[:key].find(value).to_s + "[#{value}]" rescue '???'
    end

    def assoc_klass(name)
      Object.const_set(name.classify, Class.new)
    end

    def klass
      Object.const_set(version.item_type.classify, Class.new)
    end

    def build_associations
      @assoc ||= Hash[klass
                        .reflect_on_all_associations
                        .select{ |a| a.macro == :belongs_to }
                        .map{|x| [x.foreign_key.to_s, assoc_klass(x.name)]}]
    end

    def changes
      @chs ||= YAML.load(version.object_changes).except('created_at', 'id')
    end
  end
end
