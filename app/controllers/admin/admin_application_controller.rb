class Admin::AdminApplicationController < ApplicationController

  before_filter :require_admin_priviledges

  private

    def require_admin_priviledges
      unless user_signed_in? && current_user.has_role?(:admin)
        redirect_to '/404.html'
      end
    end

end