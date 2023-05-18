require "controllers/api/v1/test"

class Api::V1::TasksControllerTest < Api::Test
  def setup
    # See `test/controllers/api/test.rb` for common set up for API tests.
    super

    @project = create(:project, team: @team)
    @task = build(:task, project: @project)
    @other_tasks = create_list(:task, 3)

    @another_task = create(:task, project: @project)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @task.save
    @another_task.save
  end

  # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
  # data we were previously providing to users _will_ break the test suite.
  def assert_proper_object_serialization(task_data)
    # Fetch the task in question and prepare to compare it's attributes.
    task = Task.find(task_data["id"])

    assert_equal_or_nil task_data['title'], task.title
    assert_equal_or_nil task_data['estimated_hours'], task.estimated_hours
    assert_equal_or_nil task_data['actual_hours'], task.actual_hours
    assert_equal_or_nil task_data['priority'], task.priority
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal task_data["project_id"], task.project_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/projects/#{@project.id}/tasks", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    task_ids_returned = response.parsed_body.map { |task| task["id"] }
    assert_includes(task_ids_returned, @task.id)

    # But not returning other people's resources.
    assert_not_includes(task_ids_returned, @other_tasks[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/tasks/#{@task.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/tasks/#{@task.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    task_data = JSON.parse(build(:task, project: nil).to_api_json.to_json)
    task_data.except!("id", "project_id", "created_at", "updated_at")
    params[:task] = task_data

    post "/api/v1/projects/#{@project.id}/tasks", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/projects/#{@project.id}/tasks",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/tasks/#{@task.id}", params: {
      access_token: access_token,
      task: {
        title: 'Alternative String Value',
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @task.reload
    assert_equal @task.title, 'Alternative String Value'
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/tasks/#{@task.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Task.count", -1) do
      delete "/api/v1/tasks/#{@task.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/tasks/#{@another_task.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
