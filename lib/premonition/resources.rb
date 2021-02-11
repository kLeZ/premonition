module Jekyll
  module Premonition
    class Resources
      attr_reader :config
      attr_reader :markdown

      def initialize(site_config)
        @config = load site_config
        @markdown = Converters::Markdown.new site_config
      end

      def load(site_config)
        cfg = default_config
        p = site_config['premonition'] || {}
        df = p['default'] || {}
        validate_defaults df, p
        cfg['default']['template'] = df['template'].strip unless df['template'].nil?
        cfg['default']['title'] = df['title'].strip unless df['title'].nil?
        cfg['default']['cite'] = df['cite'].strip unless df['cite'].nil?
        cfg['default']['meta'] = cfg['default']['meta'].merge(df['meta']) unless df['meta'].nil?
        load_types p, cfg
        cfg
      end

      def default_config
        {
          'default' => {
            'template' => '<div class="premonition {{type}}"><div class="fa {{meta.fa-icon}}"></div>'\
              '<div class="content">{% if header %}<p class="header">{{title}}</p>{% endif %}{{content}}</div></div>',
            'meta' => { 'fa-icon' => 'fa-check-square' },
            'title' => nil,
            'cite' => nil
          },
          'types' => {
            'note' => { 'meta' => { 'fa-icon' => 'fa-check-square' } },
            'info' => { 'meta' => { 'fa-icon' => 'fa-info-circle' } },
            'warning' => { 'meta' => { 'fa-icon' => 'fa-exclamation-circle' } },
            'error' => { 'meta' => { 'fa-icon' => 'fa-exclamation-triangle' } },
            'citation' => { 'meta' => { 'fa-icon' => 'fa-quote-left' }, 'template' => '<div class="premonition {{type}}"><div class="fas {{meta.fa-icon}}"></div><blockquote class="content blockquote"{% if cite %} cite="{{cite}}"{% endif %}>{{content}}{% if header %}<footer class="blockquote-footer"><cite title="{{title}}">{% if cite %}<a href="{{cite}}">{{title}}</a>{% else %}{{title}}{% endif %}</cite></footer>{% endif %}</blockquote></div>' }
          }
        }
      end

      def validate_defaults(df, prem)
        fail 'meta must be a hash' if !df['meta'].nil? && !df['meta'].is_a?(Hash)
        fail 'types must be a hash' if !prem['types'].nil? && !prem['types'].is_a?(Hash)
      end

      def load_types(p, cfg)
        return if p['types'].nil?
        p['types'].each do |id, obj|
          t = type_config id, obj
          cfg['types'][id] = cfg['types'][id].merge(t) unless cfg['types'][id].nil?
          cfg['types'][id] = t if cfg['types'][id].nil?
        end
      end

      def type_config(id, t)
        validate_type(id, t)
        {
          'template' => t['template'].nil? ? nil : t['template'].strip,
          'default_title' => t['default_title'].nil? || t['default_title'].empty? ? nil : t['default_title'].strip,
          'meta' => t['meta'].nil? ? {} : t['meta']
        }
      end

      def validate_type(id, t)
        fail 'id missing from type' if id.nil?
        fail "id can only be lowercase letters: #{id}" unless id[/[a-z]+/] == id
        fail 'meta must be an hash' if !t['meta'].nil? && !t['meta'].is_a?(Hash)
      end

      def fail(msg)
        Jekyll.logger.error 'Fatal (Premonition):', msg
        raise LoadError, msg
      end
    end
  end
end
