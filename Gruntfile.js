module.exports = function( grunt ){

	// Default
	grunt.registerTask( "default", [ "watch" ] );

	// Build All
	grunt.registerTask( "all", [ "css", "js", "copy" ] );

	// CSS Task
	grunt.registerTask( "css", [
		"clean:revcss", 		//clean old rev css
		"concat:css", 			//concat css
		"cssmin:css",			//min css
		"clean:combinedcss",	//clean concat css
		"rev:css",				//create cache buster
		"clean:mincss",			//clean min css
		"injector:css"			//inject css
	] );

	// custom js task
	grunt.registerTask( "js", [
		"clean:revjs",			//clean old rev js
		"jshint", 				//js lint
		"concat:js", 			//concat js
		"uglify:js",			//min js
		"clean:combinedjs", 	//clean combined js
		"rev:js",				//create cache buster
		"clean:minjs",			//clean min js
		"injector:js"			//inject js
	] );

	// Config
	grunt.initConfig( {
		// read configs
		pkg : grunt.file.readJSON( "package.json" ),

		// Copy UI Fonts to destination
		copy : {
			fonts : {
				files : [
					{
						expand 	: true,
						src 	: 'web_components/font-awesome/fonts/**',
						dest 	: 'includes/fonts',
						flatten : true,
						filter 	: 'isFile'
					},
					{
						expand 	: true,
						src 	: 'web_components/bootstrap/fonts/**',
						dest 	: 'includes/fonts',
						flatten : true,
						filter 	: 'isFile'
					}
				]
			}
		},

		// Concat Task
		concat : {
			css : {
	        	files : {
	            	"includes/css/databoss.css" : [
						"web_components/bootstrap/dist/css/bootstrap.min.css",
						"web_components/font-awesome/css/font-awesome.min.css",
						"web_components/bootstrap-datepicker/dist/css/bootstrap-datepicker3.min.css",
						"web_components/bootstrap3-wysihtml5-bower/dist/bootstrap3-wysihtml5.min.css",
						"web_components/clockpicker/dist/bootstrap-clockpicker.min.css",
	            		"includes/css/src/databoss.css"
	            	]
				}
			},
			js : {
	        	files : {
	            	"includes/js/databoss.js" : [
						"web_components/jquery/dist/jquery.min.js",
						"web_components/bootstrap/dist/js/bootstrap.min.js",
						"web_components/bootstrap-datepicker/dist/js/bootstrap-datepicker.min.js",
						"web_components/clockpicker/dist/jquery-clockpicker.min.js",

						"web_components/handlebars/handlebars.runtime.min.js",
						"web_components/rangy-1.3/uncompressed/rangy-core.js",
						"web_components/rangy-1.3/uncompressed/rangy-cssclassapplier.js",
						"web_components/rangy-1.3/uncompressed/rangy-highlighter.js",
						"web_components/rangy-1.3/uncompressed/rangy-selectionsaverestore.js",
						"web_components/rangy-1.3/uncompressed/rangy-serializer.js",
						"web_components/rangy-1.3/uncompressed/rangy-textrange.js",
						"web_components/wysihtml5x/dist/wysihtml5x.min.js",
						"web_components/wysihtml5x/dist/wysihtml5x-toolbar.min.js",
						"web_components/bootstrap3-wysihtml5-bower/dist/bootstrap3-wysihtml5.min.js",

	            		"includes/js/src/*.js"
	            	]
				}
			}
		}, // end concat

		// CSS Min
		cssmin : {
			css : {
				files : { "includes/css/databoss.min.css" : [ "includes/css/databoss.css" ] }
			}
		}, // end css min

		// JS Min
		uglify : {
			options : {
    			banner : "/* <%= pkg.name %> minified @ <%= grunt.template.today() %> */\n",
    			mangle : false
    		},
			js : {
				files : { "includes/js/databoss.min.js" : [ "includes/js/databoss.js"	] }
			}
		},

		// Cache Busting
		rev : {
			css : {
				files : { src : [ "includes/css/databoss.min.css" ] }
			},
			js 	: {
				files : { src : [ "includes/js/databoss.min.js" ] }
			}
		}, // end cache busting

		// Cleanup
		clean : {
			// css
			combinedcss : { src : [ "includes/css/databoss.css" ] },
			mincss 		: { src : [ "includes/css/databoss.min.css" ] },
			revcss 		: { src : [ "includes/css/*databoss.min.css" ] },
			// js
			combinedjs  	: { src : [ "includes/js/databoss.js" ] },
			minjs 			: { src : [ "includes/js/databoss.min.js" ] },
			revjs 			: { src : [ "includes/js/*databoss.min.js" ] }
		},

		// Watch
		watch : {
			css : {
				files : [ "includes/css/src/*.css" ],
				tasks : [ "css" ]
			},
			js : {
				files : [
					"includes/js/src/*.js"
				],
				tasks : [ "js" ]
			},
			grunt : {
				files : [ "Gruntfile.js" ],
				tasks : [ "all" ]
			}
		},

		// Injector
		injector : {
			options : {
				transform : function( filepath, index, length ){
					return 'addAsset( "#prc.modRoot#' + filepath.substring( 1 ) + ' ");';
				},
				starttag : "//injector:{{ext}}//",
				endtag : "//endinjector//"
			},
			css : {
				files : {
					"handlers/BaseHandler.cfc"	: [ "includes/css/*databoss.min.css" ]
				}
			},
			js : {
				files : {
					"handlers/BaseHandler.cfc"	: [ "includes/js/*databoss.min.js" ]
				}
			}
		},

		// JS Hint
		jshint : {
			options : {
				curly 	: true,
				eqeqeq  : true,
				eqnull 	: true,
				browser : true,
				devel 	: true,
				sub  	: true,
				evil	: true,
				globals : {
					jQuery 	: true,
					$ 		: true,
					module 	: true,
					angular : true
				},
				ignores : [ "*.databoss.min.js" ]
			},
			all : [
				"Gruntfile.js",
				'includes/js/src/databoss.js',
				'includes/js/src/metadata.pack.js',
				'includes/js/src/uitablefilter.js'
			]
		},

	} );

	// Load Tasks
	require( 'matchdep' )
		.filterDev( 'grunt-*' )
		.forEach( grunt.loadNpmTasks );
};