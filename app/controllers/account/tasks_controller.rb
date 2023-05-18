class Account::TasksController < Account::ApplicationController
  account_load_and_authorize_resource :task, through: :project, through_association: :tasks

  # GET /account/projects/:project_id/tasks
  # GET /account/projects/:project_id/tasks.json
  def index
    delegate_json_to_api
  end

  # GET /account/tasks/:id
  # GET /account/tasks/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/projects/:project_id/tasks/new
  def new
  end

  # GET /account/tasks/:id/edit
  def edit
  end

  # POST /account/projects/:project_id/tasks
  # POST /account/projects/:project_id/tasks.json
  def create
    respond_to do |format|
      if @task.save
        format.html { redirect_to [:account, @task], notice: I18n.t("tasks.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @task] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/tasks/:id
  # PATCH/PUT /account/tasks/:id.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to [:account, @task], notice: I18n.t("tasks.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @task] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/tasks/:id
  # DELETE /account/tasks/:id.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @project, :tasks], notice: I18n.t("tasks.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
