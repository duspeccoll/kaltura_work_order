class KalturaModel < ASpaceExport::ExportModel
  model_for :kaltura

  include JSONModel

  attr_accessor :title
  attr_accessor :component_id
  attr_accessor :description
  attr_accessor :license
  attr_accessor :related_website
  attr_accessor :tags
  attr_accessor :media_type
  attr_accessor :parts

  @archival_object_map = {
    [:title, :dates] => :handle_title,
    :component_id => :component_id=,
    :notes => :handle_notes,
    :subjects => :handle_subjects,
    :linked_agents => :handle_agents,
    :resource => :handle_resource,
    :external_documents => :handle_documents,
    :instances => :handle_instances
  }

  def initialize
    @tags = []
    @parts = []
  end

  def self.from_archival_object(obj)
    xml = self.new
    xml.apply_map(obj, @archival_object_map)

    xml
  end

  def handle_title(title, dates)
    t = title
    dates.each do |date|
      if date['label'] == "creation"
        t << ", #{date['expression']}"
      end
    end

    self.title = t
  end

  def handle_notes(notes)
    notes.select{ |n| n['type'] == "abstract" }.each do |note|
      self.description = ASpaceExport::Utils.extract_note_text(note)
    end
    notes.select{ |n| n['type'] == "userestrict" }.each do |note|
      self.license = ASpaceExport::Utils.extract_note_text(note)
    end

    if self.license.nil? || self.license.empty?
      notes.select{ |n| n['type'] == "accessrestrict" }.each do |note|
        self.license = ASpaceExport::Utils.extract_note_text(note)
      end
    end
  end

  def handle_subjects(subjects)
    subjects.map{ |s| s['_resolved'] }.each do |subject|
      subject['terms'].each do |t|
        self.tags << t['term']
      end
    end
  end

  # we have to handle agents carefully because Kaltura auto-separates commas if it sees
  # them in an indirect name
  def handle_agents(linked_agents)
    linked_agents.map{ |a| a['_resolved'] }.each do |agent|
      # ignore software agents
      next if agent['jsonmodel_type'] == "agent_software"
      name = agent['display_name']

      # kaltura will automatically split a tag if it has a comma in it, so we need to do some work
      # to export agent names properly
      if agent['jsonmodel_type'] == "agent_person" && name['name_order'] == "inverted"
        self.tags << "#{name['rest_of_name']} #{name['primary_name']}"
      else
        self.tags << name['sort_name'].gsub(",", "")
      end
    end
  end

  def handle_resource(resource)
    r = resource['_resolved']
    self.tags << "#{r['id_0']} #{r['title']}"
  end

  def handle_documents(docs)
    if !docs.nil? || !docs.empty?
      self.related_website = docs[0]['location']
    end
  end

  def handle_instances(instances)
    instances.each do |instance|
      if instance['instance_type'] == "digital_object" && instance['is_representative'] == true
        object = instance['digital_object']['_resolved']
        # assign mediaType
        self.media_type = case object['digital_object_type']
        when "moving_image"
          "1"
        when "still_image"
          "2"
        when "sound_recording" || "sound_recording_musical" || "sound_recording_nonmusical"
          "5"
        else
          nil
        end
        tree = object['tree']['_resolved']
        tree['children'].each do |child|
          self.parts << child['title']
        end
      end
    end
  end

end
