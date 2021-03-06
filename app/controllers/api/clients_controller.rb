class Api::ClientsController < ApplicationController

  def_param_group :id do
    param :id, Integer, 'Unique client id', :required => true
  end

  def_param_group :client_params do
    param :mail_address, String, 'Unique email address', :required => true
    param :password, String, 'Plaintext password', :required => true
    param :name, String, 'First name of client', :required => true
    param :last_name, String, 'Last name of client', :required => true
    param :coach_id, String, 'Id of coach', :required => true
  end

  def_param_group :update_params do
    param :is_active, :boolean, 'Indicates if user is in active state', :required => false
    param :is_pending, :boolean, 'Indicates if user is in active state', :required => false
    param :diet_plan, File, 'Diet plan for user in PDF format. Scheme, where diet plan is stored: /system/clients/:id/diet_plan/:diet_plan_file_name', :required => false
  end

  api :GET, '/clients', 'Show all clients'
  description 'Return list of all clients in system'
  param :is_active, :boolean, :desc => 'Get only active users'
  param :is_pending, :boolean, :desc => 'Get only pending users'

  def index
    is_active = params['is_active']
    clients = Client.order('updated_at DESC')
    clients = clients.where(is_active: is_active) if params['is_active']
    clients = clients.where(is_pending: params['is_pending']) if params['is_pending']

    render json: {status: 'SUCCESS', message: 'Loaded clients', data: clients}, status: :ok
  end

  api :GET, '/clients/:id', 'Get a single client details'
  param_group :id

  def show
    client = Client.find_by_id(params[:id])
    if client != nil
      render json: {status: 'SUCCESS', message: 'Client loaded', data: client}, status: :ok
    else
      render json: {status: 'FAILURE', message: 'Couldn\'t find client', data: client}, status: :not_found
    end
  end

  api :POST, '/clients', 'Create new client'
  param_group :client_params

  def create
    client = Client.new(client_params)
    if client.save
      render json: {status: 'SUCCESS', message: 'Saved client', data: client}, status: :created
    else
      render json: {status: 'ERROR', message: 'Client not saved', data: client.errors}, status: :unprocessable_entity
    end
  end

  api :PUT, '/clients/:id', 'Update client parameters'
  param_group :id
  param_group :update_params

  def update
    client = Client.find_by_id(params[:id])
    if client != nil && client.update_attributes(client_params)
      render json: {status: 'SUCCESS', message: 'Updated client', data: client}, status: :no_content
    else
      render json: {status: 'ERROR', message: 'Client not updated', data: client&.errors}, status: :not_found
    end
  end

  api :DELETE, '/clients/:id', 'Remove client'
  param_group :id

  def destroy
    client = Client.find(params[:id])
    client.destroy
    render json: {status: 'SUCCESS', message: 'Remove client with all his diet plans', data: client}, status: :ok
  end


  private

  def client_params
    params.permit(:mail_address, :password, :name, :last_name, :coach_id, :is_active, :is_pending, :diet_plan)
  end
end