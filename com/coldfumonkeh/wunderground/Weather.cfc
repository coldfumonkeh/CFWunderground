<!---
Name: Weather.cfc
Author: Matt Gifford aka coldfumonkeh (http://www.mattgifford.co.uk)
Date: 315.09.2011

Copyright 2011 Matt Gifford aka coldfumonkeh. All rights reserved.
Product and company names mentioned herein may be
trademarks or trade names of their respective owners.

Subject to the conditions below, you may, without charge:

Use, copy, modify and/or merge copies of this software and
associated documentation files (the 'Software')

Any person dealing with the Software shall not misrepresent the source of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Revision history
================

15/09/2011 - Version 1.1

	-	initial commit


--->
<cfcomponent displayname="Weather" output="false" hint="I am the Weather CFC.">
	
	<cfset variables.instance = {} />
	
	<cffunction name="init" output="false" access="public" hint="I am the constructor method for the Weather class.">
		<cfargument name="apiKey" required="true" type="string" hint="I am the API key required to access the services." />
			<cfset variables.instance.apiKey = arguments.apiKey />
		<cfreturn this />
	</cffunction>
	
	<!--- Getters / Accessors --->
	<cffunction name="getApiKey" access="public" output="false" returntype="String" hint="I return the API Key value.">
		<cfreturn variables.instance.apiKey />
	</cffunction>
	
	<!--- Public Methods --->
	<cffunction name="getWeatherReport" access="public" output="false" hint="I'll obtain your weather report for you.">
		<cfargument name="location"			required="true"  type="string" 					hint="The location for which you want weather information. Examples: CA/San_Francisco. 60290 (U.S. zip code). Australia/Sydney. 37.8,-122.4 (latitude,longitude). KJFK (airport code). AutoIP Address Location." />
		<cfargument name="geolookup" 		required="false" type="boolean" default="false" hint="Returns the the city name, zip code / postal code, latitude-longitude coordinates and nearby personal weather stations." />
		<cfargument name="conditions" 		required="false" type="boolean" default="false" hint="Returns the current temperature, weather condition, humidity, wind, 'feels like' temperature, barometric pressure, and visibility." />
		<cfargument name="forecast" 		required="false" type="boolean" default="false" hint="Returns a summary of the weather for the next 3 days. This includes high and low temperatures, a string text forecast and the conditions." />
		<cfargument name="astronomy" 		required="false" type="boolean" default="false" hint="Returns The moon phase, sunrise and sunset times." />
		<cfargument name="radar" 			required="false" type="boolean" default="false" hint="Returns a URL link to the .gif radar image." />
		<cfargument name="satellite" 		required="false" type="boolean" default="false" hint="Returns a URL link to .gif visual and infrared satellite images." />
		<cfargument name="webcams" 			required="false" type="boolean" default="false" hint="Returns locations of nearby Personal Weather Stations and URL's for images from their web cams." />
		<cfargument name="history" 			required="false" type="boolean" default="false" hint="history_YYYYMMDD returns a summary of the observed weather for the specified date." />
		<cfargument name="alerts" 			required="false" type="boolean" default="false" hint="Returns the short name description, expiration time and a long text description of a severe alert - If one has been issued for the searched upon location." />
		<cfargument name="hourly" 			required="false" type="boolean" default="false" hint="Returns an hourly forecast for the next 36 hours immediately following the API request." />
		<cfargument name="hourly7day" 		required="false" type="boolean" default="false" hint="Returns an hourly forecast for the next 7 days." />
		<cfargument name="forecast7day" 	required="false" type="boolean" default="false" hint="Returns a summary of the weather for the next 7 days. This includes high and low temperatures, a string text forecast and the conditions." />
		<cfargument name="yesterday" 		required="false" type="boolean" default="false" hint="Returns a summary of the observed weather history for yesterday." />
		<cfargument name="format" 			required="false" type="string" 	default="json" 	hint="I am the format of the request. JSON." >
		<cfargument name="parseResults"		required="false" type="boolean" default="false"	hint="A boolean value to determine if the output data is parsed or returned as a string" />
			<cfset var strResponse 	= 	'' />
			<cfset var strReturn 	= 	'' />
			<cfset var arrValues 	= 	[] />
			<cfset var strFeatures	=	'' />
			<cfset var strEndpoint 	= 	'http://api.wunderground.com/api/#getApiKey()#/' />
			<cfset var stuParams 	= 	structCopy(arguments) />
				<!--- Strip out non-feature arguments --->
				<cfset structDelete(stuParams,'location') />
				<cfset structDelete(stuParams,'format') />
				<cfset structDelete(stuParams,'parseResults') />
				<!--- Generate an array containing all requested features --->				
				<cfset arrValues 	= filterToArray(params=stuParams) />
				<!--- Build the URL structure with the requested features --->
				<cfloop array="#arrValues#" index="feature">
					<cfset strFeatures = strFeatures & feature & '/' />
				</cfloop>
				<!--- Generate the required URL --->
				<cfset strEndpoint = strEndpoint & strFeatures & 'q/' & arguments.location & '.' & arguments.format />	
				<!--- Make the request to the API --->
				<cfset strResponse 	= makeCall(requestURL=strEndpoint) />
		<cfreturn handleOutput(response=strResponse,parseResults=arguments.parseResults) />
	</cffunction>
	
	
	<cffunction name="autocomplete" access="public" output="false" hint="I will try and find locations or hurricanes using the supplied query. For example, 'San' or 'Kat'.">
		<cfargument name="query"			required="true"  type="string" 					hint="The query string which you want to obtain autocomplete suggestions for." />
		<cfargument name="c"				required="false" type="string" 	default="" 		hint="A specific country code." />
		<cfargument name="h"				required="false" type="boolean" default="0"		hint="Include hurricanes in results." />
		<cfargument name="cities"			required="false" type="boolean" default="1" 	hint="Include cities in results. If false, only hurricanes will be returned." />
		<cfargument name="cb"				required="false" type="string" 	default="" 		hint="JSONP Callback." />
		<cfargument name="format" 			required="false" type="string" 	default="json" 	hint="I am the format of the request. JSON." >
		<cfargument name="parseResults"		required="false" type="boolean" default="false"	hint="A boolean value to determine if the output data is parsed or returned as a string" />
			<cfset var strResponse 	= 	'' />
			<cfset var strReturn 	= 	'' />
			<cfset var strQryString	=	'' />
			<cfset var strEndpoint 	= 	'http://autocomplete.wunderground.com/aq?' />
			<cfset var stuParams 	= 	structCopy(arguments) />
				<!--- Strip out non-optional arguments --->
				<cfset structDelete(stuParams,'query') />
				<cfset structDelete(stuParams,'format') />
				<cfset structDelete(stuParams,'parseResults') />
				<!--- Build the query string with the values --->
				<cfset strQryString = buildParamString(stuParams) />
				<!--- Build the URL structure with the requested values --->
				<cfset strEndpoint 	= strEndpoint & 'query=' & arguments.query & '&format=' & arguments.format />	
				<!--- If query string values are present, append them to the endpoint --->						
				<cfif len(strQryString)>
					<cfset strEndpoint = strEndpoint & '&' & strQryString />
				</cfif>
				<!--- Make the request to the API --->
				<cfset strResponse = makeCall(requestURL=strEndpoint) />
		<cfreturn handleOutput(response=strResponse,parseResults=arguments.parseResults) />	
	</cffunction>

	<!--- Utils --->
	<cffunction name="handleOutput" access="private" output="false" hint="I manage the return format for the response.">
		<cfargument name="response" 	required="true" 	type="any"		hint="I am the response from the API call." />
		<cfargument name="parseResults"	required="false" 	type="boolean"  hint="A boolean value to determine if the output data is parsed or returned as a string" />
			<cfset var strReturn = '' />
				<cfif arguments.parseResults>
					<cfset strReturn = DeserializeJSON(arguments.response) />
				<cfelse>
					<cfset strReturn = serializeJSON(DeserializeJSON(arguments.response)) />
				</cfif>
		<cfreturn strReturn />
	</cffunction>
		
	<cffunction name="buildParamString" access="public" output="false" returntype="String" hint="I loop through a struct to convert to query params for the URL">
		<cfargument name="argScope" required="true" type="struct" hint="I am the struct containing the method params" />
			<cfset var strURLParam 	= '' />
			<cfloop collection="#arguments.argScope#" item="key">
				<cfif len(arguments.argScope[key])>
					<cfif listLen(strURLParam)>
						<cfset strURLParam = strURLParam & '&' />
					</cfif>	
					<cfset strURLParam = strURLParam & lcase(key) & '=' & arguments.argScope[key] />
				</cfif>
			</cfloop>
		<cfreturn strURLParam />
	</cffunction>
	
	<cffunction name="makeCall" access="public" output="false" hint="I make the request to the API.">
		<cfargument name="requestURL"	required="true"  type="string" 	hint="The URL with which to make the request." />
			<cfset var cfhttp		=	'' />
			<cfset var strResponse	=	'' />
				<cfhttp url="#arguments.requestURL#" method="get">
				<cfset strResponse = cfhttp.FileContent />
		<cfreturn strResponse />
	</cffunction>
	
	<cffunction name="filterToArray" access="private" output="false" hint="I take a structure of values and filter them down, returning an array of any values set to true.">
		<cfargument name="params" required="true" output="false" hint="I am the structure containing the values to filter." />
			<cfset var arrFilter = [] />
				<cfloop collection="#arguments.params#" item="key">
					<cfif arguments.params[key]>
						<cfset arrayAppend(arrFilter,lcase(key)) />
					</cfif>
				</cfloop>
		<cfreturn arrFilter />
	</cffunction>
	
</cfcomponent>