module TemplateHelper
  def text_field_tag_for(object_or_class_name, attribute)
    if object_or_class_name.is_a? Symbol
      class_name = object_or_class_name
    else
      class_name = object.class.name.underscore.downcase.to_sym
    end

    text_field_tag attribute, nil, data: { id: object_or_class_name.try(:id), class: class_name, attr: attribute, adq_uuid: object_or_class_name.try(:uuid) }
  end

  def template(collection:, &block)
    content_for :adq_script do
      js(
        args: {
          template: capture(&block),
          collection: collection.to_json,
        },
        rendered: true
      )
    end
  end

end
