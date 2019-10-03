class KalturaSerializer < ASpaceExport::Serializer
  serializer_for :kaltura

  include JSONModel

  def serialize(obj, opts = {})
    if obj.media_type.nil?
      raise "Invalid Kaltura media type. Objects must have a moving image, sound recording, or still image resource type."
    else
      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        serialize_object(obj, xml)
      end

      builder.to_xml
    end
  end

  def serialize_object(obj, xml)
    root_args = {
      'xmlns:xsd' => "http://www.w3.org/2001/XMLSchema",
      'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
      'xsi:noNamespaceSchemaLocation' => "ingestion.xsd"
    }

    xml.mrss(root_args) {
      xml.channel {
        obj.parts.each do |part|
          xml.item {
            xml.action { xml.text "add" } # should make this a variable the user provides
            xml.type { xml.text "1" }
            xml.userId { xml.text "kevin.clair@du.edu" } # change this later
            xml.name obj.title
            xml.description obj.description
            xml.tags {
              obj.tags.uniq.each do |tag|
                xml.tag tag
              end
            }
            xml.categories {
              xml.category { xml.text "MediaSpace&gt;site&gt;channels&gt;University Libraries Archival Audiovisual Collection" }
              xml.category { xml.text "MediaSpace&gt;site&gt;galleries&gt;Academics&gt;University Libraries&gt;Special Collections" }
            }
            if !obj.media_type.nil?
              xml.media {
                xml.mediaType obj.media_type # this varies by resource type; 1 = video, 2 = image, 5 = audio
              }
            end
            xml.contentAssets {
              xml.content {
                xml.urlContentResource(:url => "#{AppConfig[:kaltura_sftp_url]}/#{part}")
              }
            }
            xml.thumbnails {
              xml.thumbnail(:isDefault => true) {
                xml.urlContentResource(:url => "#{AppConfig[:kaltura_sftp_url]}/test.jpg")
              }
            }
            xml.customDataItems {
              xml.customData(:metadataProfileId => "10473112") {
                xml.xmlData {
                  xml.metadata {
                    xml.RelatedWebsite obj.related_website if !obj.related_website.nil?
                    xml.ReferenceID obj.component_id
                    xml.LicenseAgreement obj.license if !obj.license.nil?
                  }
                }
              }
            }
          }
        end
      }
    }
  end
end
