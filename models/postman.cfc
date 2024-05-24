component accessors="true" {

	property name="rootURL" default="{{API_Server}}";
	property name="allRoutes" default=[];
	property name="exportedArgs";
	property name="unmatched" default=[];
	property name="collectionName";
	property name="siteUrl";
	property name="defaultPath";
	property name="allExportedData";
	property name="postmanId" default="";
	property name="schema" default="https://schema.getpostman.com/json/collection/v2.1.0/collection.json";
	property name="exporterId" default="";
	property name="collectionLink" default="";

	this.memento={
		"defaultIncludes"=[
			"rootURL",
			"allRoutes",
			"exportedArgs",
			"unmatched",
			"collectionName",
			"siteURL",
			"defaultPath",
			"allExportedData",
			"postmanId",
			"schema",
			"exporterId",
			"collectionLink"
		]
	}


	function init(){
		setallExportedData( {} );
		setunmatched( [] );
		return this;
	}

	/**
	 * Provides the main keys for the postman collection
	 */
	function obtainBase(){
		var info = allExportedData.keyExists("info") ? allExportedData.info : {
			"_postman_id"      : getPostManId(),
			"name"             : getcollectionName(),
			"schema"           : getSchema(),
			"_exporter_id"     : getexporterID(),
			"_collection_link" : getCollectionLink()
		};
		var event = allExportedData.keyExists("event") ? allExportedData.event : {};
		var variabl = allExportedData.keyExists("variable") ? allExportedData.variable : [];
		var retme =  {
			"info" : info,
			"item"  : {}
		};
		if(event.len()){
			retme["event"] = event;
		}
		if(variabl.len()){
			retme["variable"] = variabl
		}
		return retme;
	}

	/**
	 * Obtains the routes from the server router using the carto module
	 *
	 * @module The name of the module whose routes you want
	 */
	function obtainRoutesFromRouter( module ){
		cfhttp( url = "#siteUrl#/carto/#module#", result = "modRouter" );
		if(!isJSON(modRouter.fileContent)){
			print.line("The response from #suteURL# was not JSON").toConsole();
			print.line(modRouter.fileContent).toConosle();
			return "";
		} else {
			return deserializeJSON( modRouter.fileContent );
		}
	}

	/**
	 * Obtains all routes from the server's routers for the modules defined in the allRoutes property and converts it to a structure
	 */
	function createRouteStructure(){
		var routes         = {};
		var routeStructure = {};

		allRoutes.each( ( module ) => {
			routes[ module ] = obtainRoutesFromRouter( module );
		} )

		allRoutes.each( ( module ) => {
			routeStructure.append( createRouteStruct( routes[ module ] ) );
		} )

		return routeStructure;
	}

	/**
	 * Accepts a filename and extracts any meta data about the request from the existing data to merge into the newly created collection from the Coldbox Router
	 *
	 * @fileName the file name of the exported Postman data from an existing collection
	 */
	function consolidateArgsFromExport( fileName ){
		var exported = readExportedJSON( fileName );
		setAllExportedData(exported);
		setpostmanId(exported.info.keyExists("_postman_id") ? exported.info._postman_id : "");
		setexporterId(exported.info.keyExists("_exporter_id") ? exported.info._exporter_id : "");
		setCollectionLink(exported.info.keyExists("_collection_link") ? exported.info._collection_link : "");
		setCollectionName(exported.info.keyExists("name") ? exported.info.name : "");
		return mapQueryParams( exported.item );
	}



	/**
	 * Receives an Array of routes and converts them to a generic structure
	 *
	 * @routes An Array of routes from the router in a Coldbox site
	 */
	function createRouteStruct( required array routes ){
		var routeStruct = {};
		routes.each( ( item ) => {
			var routeStruct = routeStruct
			var lister      = createPath( item ).listtoArray( "/" );
			lister.each( ( step, idx ) => {
				var innerPieces = lister.slice( 1, idx ).toList( "." );
				var placeHolder = routeStruct;
				innerPieces
					.listToArray( "." )
					.each( ( inner, innerIDX ) => {
						placeHolder[ inner ] = placeHolder.keyExists( inner ) ? placeHolder[ inner ] : {
							"methods" : {}
						};
						if ( innerIDX == lister.len() ) {
							var acts = {};
							if ( item.keyExists( "action" ) ) {
								if ( isValid( "struct", item.action ) ) {
									acts.append( item.action );
								} else {
									acts[ item.verbs ] = item.event;
								}
							}
							placeHolder[ inner ][ "methods" ] = acts;
						};
						placeHolder = placeHolder[ inner ];
					} );
			} )
		} );
		return routeStruct;
	}
/*
	function obtainHeaders(){
		return [
			{
				"key"   : "x-auth-token",
				"value" : "{{API_Token}}",
				"type"  : "text"
			},
			{ "key" : "appCode", "value" : "postman", "type" : "text" }
		]
	}*/

	/*

    function convertPostman(data, routeStruct) {
        return {
            'event': data.event,
            'info': data.info,
            'variable': data.variable,
            'item': processItem(data.item, routeStruct)
        }
    }

    function processItem(itemNode, compareNode) {
        var retme = {};
        return itemNode
            .filter((item) => {
                return !isNull(compareNode) && compareNode.keyExists(item.name)
            })
            .map((item) => {
                writeDump(compareNode.keyList());
                writeDump(item.name);
                return {
                    'name': item.name,
                    'item': compareNode.keyExists(item.name) && item.keyExists('item') ? processItem(
                        item.item,
                        compareNode[item.name]
                    ) : []
                }
            })
    }*/

	/**
	 * Accepts the results of createRouteStructure() and inserts them into the postman structure
	 *
	 * @routeStruct
	 */
	function routeStructToPostman( routeStruct ){
		var existing = obtainBase();
		var returnMe =  {
			"item"     : rstpNode( routeStruct, defaultPath.listToArray() )
		};
		if(existing.keyExists("info")){
			returnMe["info"] = existing.info;
		}
		if(existing.keyExists("event")){
			returnMe["event"] = existing.event;
		}
		if(existing.keyExists("variable")){
			returnMe["variable"] = existing.variable;
		}
		return returnMe;
	}

	/**
	 * Converts each route from the
	 *
	 * @itemNode
	 * @path    
	 */
	function rstpNode( itemNode, path ){
		var returnMe = [];
		if ( isValid( "struct", itemNode ) ) {
			itemNode
				.keyArray()
				.sort( "textnocase" )
				.each( ( item ) => {
					var thisItem = {};
					// Process the node normally
					if ( item == "methods" ) {
						returnMe.append(processMethods( itemNode, path ),true);

                        // If the next item in the path is the final variable, put those calls on this same depth to group like paths without
						// unnecessary folders
					} else if ( item.findNoCase( ":" ) > 0 && itemNode[ item ].keyExists( "methods" ) ) {
 						returnMe.append(processMethods( itemNode[ item ], duplicate( path ).append( item ) ),true);

						// Process the rest of the child path nodes
					} else {
						var newPath        = duplicate( path );
						thisItem[ "name" ] = item;
						thisItem[ "item" ] = rstpNode( itemNode[ item ], newPath.append( item ) );
					}

					if ( thisItem.len() ) {
						returnMe.append( thisItem );
					}
				} )
		}
		return returnMe;
	}

	function processMethods( itemNode, path ){
		var retme = []

		itemNode.methods
			.keyArray()
			.filter( ( key ) => {
				return key.len()
			} )
			.each( ( key ) => {
		
                var thisItem={}
                thisItem["name"]=itemNode.methods[key];
				var assembledpath = cleanPath( path.toList( "/" ) & ":" & key );

				//writeDump(assembledpath);
				if ( !getExportedArgs().keyExists( assembledpath ) ) {
					getUnmatched().append( assembledpath );
				} else {
					var exportedData = getExportedArgs()[ assembledPath ];
					//writeDump(exportedData);
					if ( exportedData.keyExists( "protocolProfileBehavior" ) ) {
						thisItem[ "protocolProfileBehavior" ] = exportedData.protocolProfileBehavior;
					};
					if ( exportedData.keyExists( "event" ) ) {
						thisItem[ "event" ] = exportedData.event;
					};
				}
				thisItem[ "request" ] = createRstpRequest( itemNode, key, path, assembledpath );

                retme.append(thisItem);
			} )
		return retme;
	}

	function createRstpRequest( itemNode, key, path, assembledPath ){
		var retme = {
			"method"      : "",
			"header"      : [],
			"body"        : {},
			"description" : ""
		};

		var retMe = [];
		if ( path.last().findNoCase( ":" ) > 0 ) {
			return createRequest(
				itemNode.methods[ key ],
				key,
				duplicate( path ),
				assembledPath
			);
		} else {
			return createRequest(
				itemNode.methods[ key ],
				key,
				path,
				assembledPath
			);
		}
		return retMe;
	}

	/**
	 * Assembles the
	 *
	 * @name  
	 * @method
	 * @path  
	 */
	function createRequest( name, method, path, assembledpath ){
		var importedURLData = {};

		var retme  = { "method" : arguments.method }
		var rawURL = {
			"raw"  : cleanPath( rootURL & "/" & path.toList( "/" ) ),
			"host" : [ rootURL ],
			"path" : cleanPath( path.tolist( "/" ) )
		};

		if ( getExportedArgs().keyExists( assembledpath ) ) {
			//writeDump(assembledpath);
			var impData             = getExportedArgs()[ assembledpath ];
            //if(assembledpath.findNoCase("v3/global/login")){
            //    writeDump(impData);
            //}
			//writeDump(impData);
			importedURLData[ "variable" ] = isValid( "struct", impData.request.url ) && impData.request.url.keyExists( "variable" )
			    ? impData.request.url.variable 
                : [];

			importedURLData[ "query" ] = isValid( "struct", impData.request.url ) && impData.request.url.keyExists( "query" )
			    ? impData.request.url.query 
                : [];

			if ( impData.request.keyExists( "body" ) ) {
				//writeDump("body Existed");
				//if ( !isSimpleValue(impData.request.body[ impData.request.body.mode ])){
				//	impData.request.body[ impData.request.body.mode ] = serialize( impData.request.body[ impData.request.body.mode ] );
				//}
                //writeDump(var=impData.request.body,label="posterialize"); abort;
                retme["body"]=impData.request.body;
			}
			retme[ "description" ] = impData.keyExists( "description" ) ? impData.description : "";
		}
		retMe[ "url" ] = rawURL.append( importedURLData, true );

		return retMe;
	}


	/**
	 * Reads the JSON file exported from the postman collection
	 *
	 * @fileName
	 */
	public function readExportedJSON( fileName ){
		return deserializeJSON( fileRead( expandPath( fileName ) ) );
	}



	/**
	 * Undocumented function
	 *
	 * @node The Item key from a postman route export
	 */
	private function mapQueryParams( node ){
		var mapper = {};

		node.map( ( item ) => {
			if ( item.keyExists( "item" ) ) {
				mapper.append( mapQueryParams( item.item ) );
			} else if ( item.keyExists( "request" ) && item.request.keyExists( "url" ) ) {
				var verb   = item.request.method;
				If(!item.request.url.keyExists("path")){
					//writeDump(item);
				} else {
					var mapURL = item.request.keyExists( "url" )
					? isSimpleValue( item.request.url )
					? cleanPath( item.request.url & ":" & verb )
					: cleanPath( item.request.url.path.toList( "/" ) & ":" & verb )
					: "";

					mapper[ mapURL.replaceNoCase( getrootURL() & "/", "", "all" ) ] = item;
				}
			}
		} );
		return mapper;
	}

	private function createPath( item ){
		return item.entryPoint & "/" & item.pattern;
	}

	private function cleanPath( path ){
		//writeDump(path);
		return path
			.listToArray( "/" )
			.map( ( pathItem ) => {
				return isValid( "numeric", pathItem )
				 ? ":id"
				 : pathItem.findNoCase( ":" ) > 0 && pathItem.listLen( "-" ) > 1
				 ? pathitem.listFirst( "-" )
				 : pathItem;
			} )
			.tolist( "/" )
	}

}
