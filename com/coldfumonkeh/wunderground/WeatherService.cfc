/**
*
* @file  Weather.cfc
* @author  Original programming by Matt Gifford aka coldfumonkeh (http://www.mattgifford.co.uk), Rewrite by Denard Springle (http://blog.vsgcom.net/)
* @description I am an API wrapper for the Weather Underground API (http://www.wunderground.com/weather/api)
*
*/

component output="false" displayname="weather" accessors="true"  {

	property apiKey;

	public any function init( string apiKey = '') {
		setApiKey( arguments.apiKey );
		return this;
	}

	/**
	* @displayname	getWeatherReport
	* @description	I obtain weather related data from the Weather Underground API
	* @param		required location {String} The location for which you want weather information. Examples: CA/San_Francisco. 60290 (U.S. zip code). Australia/Sydney. 37.8,-122.4 (latitude,longitude). KJFK (airport code). AutoIP Address Location.
	* @param 		alerts {Boolean} Returns the short name description, expiration time and a long text description of a severe alert - If one has been issued for the searched upon location.
	* @param 		almanac {Boolean} Returns the average high and low temperature going back as far as Weather Underground has data for OR from National Weather Service going back 30 years.
	* @param 		astronomy {Boolean} Returns The moon phase, sunrise and sunset times.
	* @param 		conditions {Boolean} Returns the current temperature, weather condition, humidity, wind, 'feels like' temperature, barometric pressure, and visibility.
	* @param 		currenthurricane {Boolean} Returns information about current hurricanes and tropical storms.
	* @param 		forecast {Boolean} Returns a summary of the weather for the next 3 days. This includes high and low temperatures, a string text forecast and the conditions.
	* @param 		forecast10day {Boolean} Returns a summary of the weather for the next 10 days. This includes high and low temperatures, a string text forecast and the conditions.
	* @param 		geolookup {Boolean} Returns the city name, zip code / postal code, latitude-longitude coordinates and nearby personal weather stations.
	* @param 		history {Boolean} Returns a summary of the observed weather for the specified date.
	* @param 		hourly {Boolean} Returns an hourly forecast for the next 36 hours immediately following the API request.
	* @param 		hourly10day {Boolean} Returns a summary of the weather for the next 10 days. This includes high and low temperatures, a string text forecast and the conditions.
	* @param 		planner {Boolean} Returns a weather summary based on historical information between the specified dates (30 days max).
	* @param 		rawtide {Boolean} Returns raw tidal information (e.g. for use in graphs).
	* @param 		satellite {Boolean} Returns a URL link to .gif visual and infrared satellite images.
	* @param 		tide (Boolean) Returns tide information.
	* @param 		webcams (Boolean) Returns locations of nearby Personal Weather Stations and URLs for images from their web cams.
	* @param 		yesterday {Boolean} Returns a summary of the observed weather history for yesterday.
	* @param 		parse {Boolean} default: false. I am a flag to determine if the results are parsed to a structure before being returned
	* @param 		format (String) default: json. I am the format of the results to return. One of: xml or json.
	* @param 		historyDate (Date) Required for 'history' feature - the date to get historical records for in YYYYMMDD (20150708) format
	* @param 		plannerDates (String) Required for 'planner' feature - the date range to get weather for in the format MMDDMMDD (07080714)
	* @returnType	any
	*/
	public any function getWeatherReport( 
		required string location, 
		boolean alerts,
		boolean almanac,
		boolean astronomy, 
		boolean conditions, 
		boolean currenthurricane,
		boolean forecast, 
		boolean forecast10day,
		boolean geolookup,
		boolean history,
		boolean hourly, 
		boolean hourly10day,
		boolean planner,
		boolean rawtide, 
		boolean satellite, 
		boolean tide,
		boolean webcams, 
		boolean yesterday,
		boolean parse = false,
		string format = 'json',
		date historydate = now(),
		string plannerdates = dateFormat( now(), 'mmdd' ) & dateFormat( dateAdd( 'd', 30, now() ), 'mmdd' )
	) {

		// set up the initial endpoint
		var endpoint = 'http://api.wunderground.com/api/#getApiKey()#/';
		// var scope features
		var features = '';
		var arg = '';

		// loop through passed in arguments
		for( arg in arguments ) {

			// not an image request, check if this argument should be ignored
			if( !listFind( 'location,format,parse,historyDate,plabberDates', arg ) ) {
				// it shouldn't, check if this is a planner or history request
				if( ( arg neq 'history' && arg neq 'planner' ) && ( isBoolean( arguments[ arg ] ) && arguments[ arg ] ) ) {
					// it isn't, add to list of features to return
					features = features & arg & '/';
				// otherwise, check if this is a history request and the date has been provided
				} else if( ( arg eq 'history' and isDate( arguments.historyDate ) ) && ( isBoolean( arguments[ arg ] ) && arguments[ arg ] ) ) {
					// it is and it has, add the date to the feature parameters
					features = features & arg & '_' & dateFormat( arguments.historyDate, 'yyyymmdd' );
				// otherwise, check if this is a planner request and the planner dates have a length
				} else if( ( arg eq 'planner' and len( arguments.plannerDates ) ) && ( isBoolean( arguments[ arg ] ) && arguments[ arg ] ) ) {
					// it is and it does, add the dates to the feature parameters
					features = features & arg & '_' & arguments.plannerDates;
				}
			}

		} // end loopting through the passed in arguments

		// finish setting up the endpoint with features, location and format
		endpoint = endpoint & features & 'q/' & arguments.location & '.' & arguments.format;

		// return the results, parsed or not
		return doApiCall( endpoint, arguments.parse, arguments.format );

	}


	/**
	* @displayname	getWeatherImagery
	* @description	I obtain weather related imagery from the Weather Underground API
	* @param		required location {String} The location for which you want weather imagery. Examples: CA/San_Francisco. 60290 (U.S. zip code). Australia/Sydney. 37.8,-122.4 (latitude,longitude). KJFK (airport code). AutoIP Address Location.
	* @param 		animatedradar {Boolean} Returns an animated radar image for a given location.
	* @param 		animatedsatellite {Boolean} Returns an animated satellite image for a given location.
	* @param 		radar {Boolean} Returns a static radar image for a given location.
	* @param 		sattelite {Boolean} Returns a static satellite image for a given location.
	* @param 		format (String) default: gif. I am the format of the results to return. One of: gif, png or swf (SWF supported by animatedradar only, animatedsattelite must use GIF format).
	* @param 		params {Struct} I am a structure of optional parameters to define the returned imagery. See http://www.wunderground.com/weather/api/d/docs?d=layers/radar for all optoinal parameters
	* @returnType	any
	*/
	public any function getWeatherImagery(
		required string location,
		boolean animatedradar,
		boolean animateSatellite,
		boolean radar,
		boolean satellite,
		string format = 'gif',
		struct params = {}
	) {

		// set up the initial endpoint
		var endpoint = 'http://api.wunderground.com/api/#getApiKey()#/';
		// var scope function variables
		var features = '';
		var apiParams = '';
		var ix = 0;
		var param = '';

		// loop through passed in arguments
		for( arg in arguments ) {

			// not an image request, check if this argument should be ignored
			if( ( !listFind( 'location,format,parse,params', arg ) ) && ( isBoolean( arguments[ arg ] ) && arguments[ arg ] ) ) {
				// it shouldn't, add to list of features to return
				features = featured & arg & '/';
			}

		} // end loopting through the passed in arguments

		// check if there are additional params to pass
		if( !structIsEmpty( arguments.params ) ) {
			// there are, loop through them
			for( param in arguments.params ) {
				// increment index
				ix++
				// add parameters to apiParams variable
				apiParams = apiParams & ( ( iX eq 1 ) ? '?' : '&' ) & lCase( param ) & '=' & arguments.params[ param ];
			}
		}

		// finish setting up the endpoint with features, location and format
		endpoint = endpoint & features & 'q/' & arguments.location & '.' & arguments.format & apiParams;

		// return the results, parsed or not
		return doApiCall( endpoint, false, arguments.format );

	}


	/**
	* @displayname	autocomplete
	* @description	I will try and find locations or hurricanes using the supplied query. For example, 'San' or 'Kat'.
	* @param		required query {String} The query string which you want to obtain autocomplete suggestions for.
	* @param 		c {String} A specific country code to limit results to
	* @param 		h {Boolean} default: 0. Include hurricanes in results (1) or not (0)
	* @param 		cities {Boolean} default: 1. Include cities in results (1) or not (0). If false (0), only hurricanes will be returned.
	* @param 		cb {String} JSONP Callback.
	* @param 		format (String) default: json. I am the format of the results to return. One of: xml or json.
	* @param 		parse {Boolean} default: false. I am a flag to determine if the results are parsed to a structure before being returned
	* @returnType	any
	*/
	public any function autocomplete(
		required string query,
		string c,
		boolean h = 0,
		boolean cities = 1,
		string cb,
		string format = 'json',
		boolean parse = false
	) {

		// set-up initial endpoint
		var endpoint = 'http://autocomplete.wunderground.com/aq?';
		// var scope function variables
		var apiParams = '';
		var ix = 0;

		// loop through the arguments
		for( arg in arguments ) {
			// check if this argument should be ignored and has length
			if( !listFind( 'query,parse', arg ) && len( arguments[ arg ] ) ) {
				// it does, increment index
				ix++
				// add parameters to apiParams variable 
				apiParams = apiParams & ( ( iX eq 1 ) ? '?' : '&' ) & lCase( arg ) & '=' & arguments[ arg ];
			}
		}

		// finish setting up the endpoint with query and parameters
		endpoint = endpoint & arguments.query & apiParams;

		// return the results, parsed or not
		return doApiCall( endpoint, arguments.parse, arguments.format );

	}


	/**
	* @displayname	doApiCall
	* @description	I make the call to the Weather Underground API and return results
	* @param		required endpoint {String} I am the constructed endpoint URL
	* @param 		parse {Boolean} default: false. I am a flag to determine if the response should be parsed to a struct (true) or not (false)
	* @param 		format {String} default: 'json'. I am the format of the request being made, one of: json, xml, gif, png or swf
	* @returnType	any
	*/
	private any function doApiCall( required string endpoint, boolean parse = false, string format = 'json' ) {

		// get a new http service
   		var httpService = new http();
   		var result = '';

   		// configure the service
	    httpService.setMethod("get"); 
	    httpService.setCharset("utf-8"); 
	    httpService.setUrl( arguments.endpoint ); 

	    // get the result of the API call
	    result = httpService.send().getPrefix(); 

	    // check if we're parsing the results (arguments.parse = true)
	    if( arguments.parse ) {
	    	// we are, check if we're getting 'json' format
	    	if( arguments.format EQ 'json' ) {
	    		// we are, return a structure from the json
	    		return deserializeJSON( result.fileContent );
	    	// otherwise, check if we're getting 'xml' format
	    	} else if (arguments.format EQ 'xml' ) {
	    		// we are, return a structure from the XML
	    		return xmlParse( result.fileContent );
	    	// otherwise 
	    	} else {
	    		// we're getting an image format, just return the content
	    		return result.fileContent;
	    	}
	    // otherwise
	    } else {
	    	// we're not parsing, just return the content
	    	return result.fileContent;
	    }

	}

}
