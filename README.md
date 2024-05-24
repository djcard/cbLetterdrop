# cbLetterDrop

CBLetterdrop is a CommandBox module which is designed to read a Coldbox router and export the routes to use in a Postman Collection. it can also read an existing Postman export to preserve example data, scripts and other settings which are already existing in the collection. It defaults to, but does not require, using /resources/postman as an export folder which roughly follow a convention started by CBMigrations.  

## Installation

From CommandBox type `box install commandbox-cbLetterDrop`

## Usage

1. Configure a project.  
2. Export the existing collection from Postman.  
3. Use the `lade` command to create the .json file to import into Postman.  
4. Import the new file into postman to see and use the collection.  


### Configuring a project

Command: `letterDrop Configure ....`
Properties:
collectionName - The name of the collection in Postman. For an existing, this should match the existing name in order to prevent an "are you sure" prompt.
entryPoint - Any part of the URL used to call an endpoint which is inherited by the module. For example, if the module is "v1" but the actual endpoint path is "api/v1", the entry point would be "api".  
moduleList - Optional. A list of modules to import from the router. 

siteURL - The value to use as the domain. This can be a literal domain name (i.e. http://mysite.com) or a variable ( i.e. {{API_URL}} ) which would be set in the collection or global scope of Postman. See https://learning.postman.com/docs/sending-requests/variables/variables/ for more information.

modulePath - Optional but recommended. This is the folder where modules are stored in your all. For example, if the majority of your modules are in /modules_app/api/modules_app, use that as your module folder and be sure to set "api" as your entry point.  
scanModulePath - If this is set to true, when creating an export, this will scan the modulePath folder for modules and use that list to get the routes to export.  


### Creating an export

Command: `letterDrop lade ....`
Properties:  
project - The name of the project configured using `letterDrop configure`
postmanExportFile - Optional. The name of a portman export file ( .json ) to use. This can be an absolute filepath or, if relative, will default to lookingin the /resources/postman folder relative to the current folder.  
outputPath - Optional. Will default to /resources/postman relative to the current folder.  
