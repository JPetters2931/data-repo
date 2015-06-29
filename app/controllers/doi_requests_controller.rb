class DoiRequestsController < ApplicationController

  load_and_authorize_resource

  before_action :find_ezid_doi, :only => [:view_doi, :modify_metadata]
  
  def index
    @doi_requests = DoiRequest.sorted
  end

  def pending_requests
    @doi_requests = DoiRequest.pending
    render('index')
  end

  def completed_requests
    @doi_requests = DoiRequest.completed
    render('index')
  end

  def create
    if params[:collection_id].present?
      @collection = Collection.find(params[:collection_id])
      @collection[:identifier] << "doi:pending"
      puts params[:collection_id]
      doi_request = DoiRequest.new(asset_type: 'Collection', collection_id: params[:collection_id])
      if doi_request.save && @collection.update_attributes({:identifier => @collection[:identifier]})
        flash[:notice] = "DOI Request has been submitted successfully!"
      else
        flash[:error] = "DOI Request error!"
      end
      redirect_to collections.collection_path(@collection)
    else
      redirect_to doi_requsts_path
    end  
  end

  def mint_doi
    @doi_request = DoiRequest.find(params[:id])
    
    if @doi_request.asset_type == 'Collection'
      @collection = Collection.find(@doi_request.collection_id)
      minted_doi = Ezid::Identifier.create(
        datacite_creator: @collection.creator.first, 
        datacite_resourcetype: "Collection",
        datacite_title: @collection.title,
        datacite_publisher: @collection.publisher.first,
        datacite_publicationyear: @collection.date_created.first
         )
      @collection[:identifier].each_with_index {
        |id, idx| id == "doi:pending" ? @collection[:identifier][idx] = minted_doi.id : id
      }
      if @doi_request.update_attributes({:ezid_doi => minted_doi.id, :completed => true}) && 
        @collection.update_attributes({:identifier => @collection[:identifier]})
        flash[:notice] = "DOI has been minted successfully!"
        redirect_to collections.collection_path(@doi_request.collection_id)
      else
        flash[:error] = "DOI Request error!"
        redirect_to doi_requsts_path
      end
    else
      redirect_to doi_requsts_path    
    end
  end

  def mint_all
  end

  def view_doi
  end

  def modify_metadata
    if @doi_request.asset_type == 'Collection'
      @collection = Collection.find(@doi_request.collection_id)
      @ezid_doi.update_metadata(
        datacite_creator: @collection.creator.first, 
        datacite_title: @collection.title,
        datacite_publisher: @collection.publisher.first,
        datacite_publicationyear: @collection.date_created.first
         )
      if @ezid_doi.save
        flash[:notice] = "DOI metadata has been modified successfully!"
        redirect_to collections.collection_path(@collection)
      else
        flash[:error] = "DOI modification error!" 
        redirect_to doi_requsts_path
      end
    else
      redirect_to doi_requsts_path
    end
  end

  private

  def find_ezid_doi
    if params[:id]
      @doi_request = DoiRequest.find(params[:id])
      @ezid_doi = Ezid::Identifier.find(@doi_request.ezid_doi)
    end
  end

end

