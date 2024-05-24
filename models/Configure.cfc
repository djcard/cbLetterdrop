component {
    property name="print" inject="printBuffer";

    function scanFolderForModules( folder ){
        var retme = {}
		var subDirs = directoriesInPath( folder );
        return subDirs.filter((item)=>{
                return fileExists(item & "/moduleConfig.cfc");
            }).map((item)=>{
                return item.listLast("/\");
            }).tolist().replaceNoCase('"',"","all");
	}

	function directoriesInPath( path ){
		return directoryList(
			path     = path,
			recurse  = false,
			listinfo = path,
			sort     = "asc",
			type     = "dir"
		);
	}
}