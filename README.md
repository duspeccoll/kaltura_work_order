# Kaltura Work Order

API call to generate a Kaltura XML representation of item-level metadata for bulk upload.

Call can be made by appending `kaltura.xml` to any Archival Object URI. The API will return an XML document containing metadata used in Kaltura to describe audiovisual materials from Special Collections and Archives, validated against the Kaltura XML schema. For each item, the returned XML document will return one `mrss/channel` xpath, with one `<item>` node per file contained in the digital object. This node contains:

* the action to be taken by Kaltura (currently only "add" is supported; support for "update" and "delete" will come later)
* the type of material being added (only audio, video, or still image supported; any other indicated resource type will throw an error)
* the name
* the description/abstract
* the location on the Kaltura FTP server where Kaltura may find the files to be uploaded

## Configuration settings

You will need to add a configuration setting to your `config/config.rb` file in ArchivesSpace for this to work. This setting is **AppConfig[:kaltura_sftp_url]**, and it is formatted as follows:

`sftp://${login}:${password}@{kaltura_url}${path}`

Where ${login} is your Kaltura FTP login, ${password} is your Kaltura FTP password, ${kaltura_url} is the specific URL for your Kaltura FTP server, and ${path} is the directory on your server where file transfers are to be staged. Contact your Kaltura system administrator for values to provide for these local variables.

## Pain Points

* It only runs on one archival object at a time, which could be a bother if someone wants to bulk upload multiple archival objects (in which case you would need to export them one by one and then write another script to build the entire bulk upload object). You could probably write a frontend piece to do that, but that's not in this commit.

## Questions

kevin [at] jackflaps.net
