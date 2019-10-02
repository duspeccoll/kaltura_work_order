class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/repositories/:repo_id/archival_objects/:id/kaltura.xml')
    .description("Get a Kaltura XML representation of the files associated with an Archival Object")
    .params(["id", :id],
            ["repo_id", :repo_id])
    .permissions([:view_repository])
    .returns([200, "OK"]) \
  do
    obj = resolve_references(ArchivalObject.to_jsonmodel(params[:id]), ['resource', 'subjects', 'linked_agents', 'digital_object', 'digital_object::tree'])
    xml = ASpaceExport.model(:kaltura).from_archival_object(JSONModel(:archival_object).new(obj))

    xml_response(ASpaceExport::serialize(xml))
  end
end
