module TemplateHelper
  def template(model: nil, collection: nil, target_uuid: nil, meta: nil, &block)
    model_name = model

    @kindred_hash ||= {}
    @kindred_hash.merge!({
      model_name => {
        template: capture(&block),
        collection: collection,
        target_uuid: target_uuid,
        meta: meta
      }
    })
    self.controller.instance_variable_set(:@kindred_hash, @kindred_hash)
    return nil
  end

  def target(object)
    "data-target data-target-uuid=" + k_try(object, :uuid).to_s
  end

  def k_content_tag(element, attribute = nil, object = nil, content_or_options_with_block = nil, options = {}, escape = true, &block)
    content_tag(element, nil, options.merge({data: { attr: attribute, k_uuid: k_try(object, :uuid), val: object.try(attribute.to_sym)} }))
  end

  def k_hidden_field_tag(name, value=nil, object=nil, delegate_to=nil, options = {})
    hidden_field_tag name, value, options.merge({data: { attr: name, k_uuid: k_try(object, :uuid), val: value } })
  end

  def k_text_field_tag(object, attribute, options={})
    text_field_tag attribute, nil, options.merge({data: { attr: attribute, k_uuid: k_try(object, :uuid), val: "" } })
  end

  def k_check_box_tag(object, name, value=nil, checked = false, options = {})
    check_box_tag name, value, checked, options.merge({data: { attr: name, k_uuid: k_try(object, :uuid), val: ""} })
  end

  def k_select_tag(object, name, option_tags = nil, options = {})
    select_tag name, option_tags, options.merge(data: { attr: name, k_uuid: k_try(object, :uuid), val: "" })
  end

  def error_for(object, attribute)
    tag("small", data: {error: "", k_uuid: '', attr: attribute}, class: "error")
  end

  def kindred_model_data
    "<div data-kindred-model style='display:none;'></div>".html_safe
  end

  def k_try(object, method)
    unless object.is_a?(Symbol)
      object.try method
    end
  end

end
