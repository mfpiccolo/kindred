module TemplateHelper
  def template(model: nil, collection: nil, target:, &block)
    model_name = if collection.present?
      ActiveModel::Naming.singular(LineItem.first)
    else
      model
    end

    @kindred_hash ||= {}
    @kindred_hash.merge!({
      model_name => {
        template: capture(&block),
        collection: collection,
      }
    })
    self.controller.instance_variable_set(:@kindred_hash, @kindred_hash)
    return nil
  end

  # def template(collection:, &block)
  #   content_for :kindred_script do
  #     js(
  #       args: {
  #         template: capture(&block),
  #         collection: collection.to_json,
  #       },
  #       rendered: true
  #     )
  #   end
  # end

  # TODO write five methods for each type of input
  def k_text_field_tag(object_or_class_name, attribute)
    class_name = set_class_name(object_or_class_name)
    text_field_tag attribute, nil, data: { attr: attribute, k_uuid: object_or_class_name.try(:uuid), val: "" }
  end

  def k_check_box_tag(object_or_class_name, name, value=nil, checked = false, options = {})
    class_name = set_class_name(object_or_class_name)
    check_box_tag name, value, checked, data: { attr: name, k_uuid: object_or_class_name.try(:uuid), val: "" }
  end

  def k_select_tag(object_or_class_name, name, option_tags = nil, options = {})
    class_name = set_class_name(object_or_class_name)
    select_tag name, option_tags, data: { attr: name, k_uuid: object_or_class_name.try(:uuid), val: "" }
  end

  def error_for(object_or_class_name, attribute)
    tag("small", data: {error: "", k_uuid: '', attr: attribute}, class: "error")
  end

  def kindred_model_data
    "<div data-kindred-model style='display:none;'></div>".html_safe
  end


  private

  def set_class_name(object_or_class_name)
    if object_or_class_name.is_a? Symbol
      object_or_class_name
    else
      object_or_class_name.class.name.underscore.downcase.to_sym
    end
  end

end
