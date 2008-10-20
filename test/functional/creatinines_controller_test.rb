require 'test_helper'

class CreatininesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :patient_id => patients(:one)
    assert_response :success
    assert_not_nil assigns(:creatinines)
  end

  def test_should_get_new
    get :new, :patient_id => patients(:one)
    assert_response :success
  end

  def test_should_create_creatinine
    assert_difference('Creatinine.count') do
      post :create, :patient_id => patients(:one), :creatinine => { :tested_at => '2007-07-07 22:23:23', :level => 100.0, :unit => 'mg/mL' }
    end

    assert_redirected_to patient_creatinine_path(assigns(:patient), assigns(:creatinine))
  end

  def test_should_show_creatinine
    get :show, :patient_id => patients(:one), :id => creatinines(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :patient_id => patients(:one), :id => creatinines(:one).id
    assert_response :success
  end

  def test_should_update_creatinine
    put :update, :patient_id => patients(:one), :id => creatinines(:one).id, :creatinine => { }
    assert_redirected_to patient_creatinine_path(assigns(:patient), assigns(:creatinine))
  end

  def test_should_destroy_creatinine
    assert_difference('Creatinine.count', -1) do
      delete :destroy, :patient_id => patients(:one), :id => creatinines(:one).id
    end

    assert_redirected_to patient_creatinines_path(assigns(:patient))
  end
end