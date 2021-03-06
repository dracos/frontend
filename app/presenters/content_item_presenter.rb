class ContentItemPresenter
  attr_reader :content_item

  def initialize(content_item)
    @content_item = content_item
  end

  PASS_THROUGH_KEYS = [
    :base_path, :details, :description, :locale, :title
  ].freeze

  PASS_THROUGH_KEYS.each do |key|
    define_method key do
      content_item[key.to_s]
    end
  end

  def in_beta
    @content_item['phase'] == 'beta'
  end

  def slug
    URI.parse(base_path).path.sub(%r{\A/}, "")
  end

  def updated_at
    date = @content_item["updated_at"]
    DateTime.parse(date).in_time_zone if date
  end

  def format
    @content_item['schema_name']
  end

  def short_description
    nil
  end
end
