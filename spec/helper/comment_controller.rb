class CommentController < ActionController::Base

  desc "list all comments"
  def index
  end

  describe :show, "shows a comment by :id"
  def show
  end

  desc "(invokes the action that) edits the comment",
       "shows the same comment (as well)"
  def edit
  end

  describe :update, "edits a comment",
                    "shows the same comment (if the value is) in @comment"
  def update
  end

  desc "deletes", "deletes from @comments"
  def destroy
  end

end
