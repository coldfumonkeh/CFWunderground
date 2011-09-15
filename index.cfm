<!---
Name: index.cfm
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


<!--- Instantiate the Weather Underground component, passing in your apiKey --->

<cfset objWeather = createObject("component","com.coldfumonkeh.wunderground.Weather").init(apiKey='< your api key here >') />

<!--- Run an autocomplete to obtain locations using a simple query string --->
<cfset dataAutoComplete = objWeather.autocomplete(query='Kat') />

<cfdump var="#dataAutoComplete#" />

<!--- Run a search for weather report with forecast, webcam images, history and geolookup for a specific location (UK/London) --->

<cfset dataWeatherReport = objWeather.getWeatherReport(location='UK/London',geolookup=true,forecast=true,webcams=true,history=true,parseResults=true) />

<cfdump var="#dataWeatherReport#" />
