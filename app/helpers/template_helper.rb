module TemplateHelper

  def template(collection:, &block)
    content_for :kindred_script do
      js(
        args: {
          template: capture(&block),
          collection: collection.to_json,
        },
        rendered: true
      )
    end
  end

  # TODO write five methods for each type of input
  def text_field_tag_for(object_or_class_name, attribute)
    if object_or_class_name.is_a? Symbol
      class_name = object_or_class_name
    else
      class_name = object.class.name.underscore.downcase.to_sym
    end

    text_field_tag attribute, nil, data: { attr: attribute, k_uuid: object_or_class_name.try(:uuid), val: "" }
  end

  def error_for(object_or_class_name, attribute)
    tag("small", data: {error: "", k_uuid: '', attr: attribute}, class: "error")
  end

  def kindred_model_data
    "<div data-kindred-model style='display:none;'></div>".html_safe
  end

end
