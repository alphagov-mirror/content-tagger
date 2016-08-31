module HeaderHelper
  # Generates a header with `title` and `breadcrumbs`. Last item in the
  # breadcrumbs array should be a string for the "active" entry.
  def display_header(title:, breadcrumbs:, page_title: nil, page_type: nil)
    breadcrumbs = breadcrumbs.compact
    active_item = breadcrumbs.pop

    locals = {
      title: title,
      breadcrumbs: breadcrumbs,
      page_title: page_title || title,
      active_item: active_item.try(:title) || active_item,
      callout_presenter: CalloutPresenter.new(title: title, page_type: page_type)
    }

    render layout: 'shared/header', locals: locals do
      yield if block_given?
    end
  end

  def auto_link(object)
    if object.is_a?(ActiveRecord::Base)
      link_to object.title, object
    elsif object.to_s.starts_with?('<a href')
      raw object
    else
      link_to object.to_s.humanize, object.to_sym
    end
  end
end
