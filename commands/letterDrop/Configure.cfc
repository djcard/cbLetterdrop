component {

    /***
     * Configures the presets for a Postman collection and the settings needed.
     *
     * @collectionName The Name of this collection. In postman, collections of the same name will overwrite each other so avoid generic names like `API`
     * @siteURL The URL of the site you are trying to model. It is essential to have the `Carto` module installed on the server this hits so it is recommended to only point this to a development server, not production.
     * @entryPoint Any path information which precedes the individual routes. i.e. The route is defined as /mypath but when called `api/v1/` precedes it.
     * @moduleList A comma delimited list of module to include in the collection
     * @modulePath The path to the module folder of the site to model. This will scan for Coldbox modules (folders with a ModuleConfig.cfc in them) and use that value as the `moduleList`
     * @scanModulePath Whether to scan the modulePath and use that as the source of the moduleList.
     * @outputPath Where to write the export to be imported into Postman. Defaults to `resources/postman` in the current folder.
     * */
    function run(
        string collectionName,
        string siteURL,
        string entryPoint,
        string moduleList,
        string modulePath,
        string scanModulePath,
        string outputPath = getCwd() & '/resources/postman'
    ) {
        command('config set modules.cbLetterDrop.projects[#arguments.collectionName#]=#serializeJSON(arguments)#').run();
        command('r').run();
    }

}
