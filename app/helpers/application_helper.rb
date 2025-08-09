module ApplicationHelper
  # Returns ▲ or ▼ for the currently sorted column, or nothing if not sorted
  def sort_arrow(column)
    if params[:sort] == column
      params[:direction] == 'asc' ? '▲' : '▼'
    else
      ''
    end
  end
end
