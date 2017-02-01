module BreadcrumbsHelper
  def breadcrumbs(e, extra=nil)
    return "#{breadcrumbs(e)}<li class=\"mu-breadcrumb-list-item\">#{extra}</li>".html_safe if extra

    base = link_to_path_element e
    if e.navigation_end?
      "<li class=\"mu-breadcrumb-list-item\">#{base}</li>".html_safe
    else
      "#{breadcrumbs(e.navigable_parent)} <li class=\"mu-breadcrumb-list-item\">#{base}</li>".html_safe
    end
  end
end
