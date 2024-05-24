component {

    property name="projects" inject="commandbox:configSettings:modules.cbLetterDrop.projects";


    /* *
     *
     * @project The name of a the configured project
     * @postmanExportFile Optional value of a postman export which contains information and examples about the selected collection
     * @outputPath Optional folder to export the collection. Defaults to the /resources/postman relative to the current folder
     */

    void function run(
        required string project,
        string postmanExportFile = '',
        string outputPath = getcwd() & '/resources/postman'
    ) {
        var projData = projects.keyExists(arguments.project)
         ? projects[arguments.project]
         : {};

        print.line(projData);

        var postmanPath = arguments.postmanExportFile.listLen('/\') == 1
         ? getCwd() & '/resources/postman/' & arguments.postmanExportFile
         : arguments.postmanExportFile;
        var parser = new letterdrop.models.postman();
        print.line('Parser made').toConsole();
        parser.setexportedArgs(parser.consolidateArgsFromExport(fileName = postmanPath));

        print.line(parser.getCollectionName());
        if (parser.getCollectionName().len() && projData.collectionName != parser.getCollectionName()) {
            var cont = ask(
                message = 'The names of the source data and the project do not match. Continue?: y/n',
                defaultResponse = 'y'
            );
            if (cont != 'y') {
                return;
            }
        }
        parser.setcollectionName(projData.collectionName);
        parser.setSiteUrl(projData.siteURL);
        parser.setAllRoutes(projData.moduleList);
        parser.setDefaultPath(projData.entryPoint);

        var routeStructure = parser.createRouteStructure();

        var convertedRouteStruct = parser.routeStructToPostman(routeStructure);
        var wholePath = expandPath(
            arguments.outputPath & '/#projData.collectionName##dateFormat(now(), 'yyyy-mm-dd')#.json'
        );
        fileWrite(
            expandPath(arguments.outputPath & '/#projData.collectionName##dateFormat(now(), 'yyyy-mm-dd')#.json'),
            serializeJSON(convertedRouteStruct)
        );
        print.line(wholePath);
        print.line('Done');
    }

}
