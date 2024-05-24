/**
 * Command to obtain the list of modules in a folder to help in configuration. 
 */
component {
    property name="configs" inject="Configure@letterDrop";

    /**
     * Undocumented function
     *
     * @modulePath The folder to scan for modules. A module is defined as an immediate subfolder with a ModuleConfig.cfc file in it. 
     */
    void function run( required string modulePath ){
       print.line(configs.scanFolderForModules(arguments.modulePath)); 
    }
}