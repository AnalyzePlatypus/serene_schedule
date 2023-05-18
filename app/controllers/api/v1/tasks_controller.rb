# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::TasksController < Api::V1::ApplicationController
    account_load_and_authorize_resource :task, through: :project, through_association: :tasks

    # GET /api/v1/projects/:project_id/tasks
    def index
    end

    # GET /api/v1/tasks/:id
    def show
    end

    # POST /api/v1/projects/:project_id/tasks
    def create
      if @task.save
        render :show, status: :created, location: [:api, :v1, @task]
      else
        render json: @task.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/tasks/:id
    def update
      if @task.update(task_params)
        render :show
      else
        render json: @task.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/tasks/:id
    def destroy
      @task.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def task_params
        strong_params = params.require(:task).permit(
          *permitted_fields,
          :title,
          :notes,
          :estimated_hours,
          :actual_hours,
          :priority,
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays,
          # 🚅 super scaffolding will insert new arrays above this line.
        )

        process_params(strong_params)

        strong_params
      end
    end

    include StrongParameters
  end
else
  class Api::V1::TasksController
  end
end
