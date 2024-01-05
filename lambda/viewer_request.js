
function handler (event) {
  // Extract the request from the CloudFront event that is sent to Lambda@Edge
  var request = event.request;
  var host = request.headers.host.value;
  var aliases = ${redirect_from_list};
  var redirectTo = "${redirect_to}";

  for (var i = 0; i < aliases.length; i++) {
    var alias = aliases[i];
    if (host === alias) {
      var response = {
        statusCode: 301,
        statusDescription: 'Redirecting to website domain',
        headers:
          {"location": {"value": `https://$${redirectTo}$${request.uri}`}}
      }

      return response;
    }
  }

// %{ if append_slash }
  // Start append_slash
  var olduri = request.uri;
  // Match any uri that ends with some combination of
  // [0-9][a-z][A-Z]_- and append a slash
  var endslashuri = olduri.replace(/(\/[\w\-]+)$/, '$1/');
  if(endslashuri !== olduri) {
    // If we changed the uri, 301 to the version with a slash, appending querystring
    var params = '';
    if(('querystring' in request) && (request.querystring.length>0)) {
      params = '?'+request.querystring;
    }
    var newuri = endslashuri + params;

    var response = {
      statusCode: 301,
      statusDescription: 'Permanently moved',
      headers:
        { "location": { "value": `//$${host}$${newuri}` } }
    }

    return response;
  }
// %{endif}

// %{ if index_rewrite }
    // Start index_rewrite
    // Extract the URI from the request
    var olduri = request.uri;

    // Match any '/' that occurs at the end of a URI. Replace it with a default index
    var newuri = olduri.replace(/\/$/, '\/index.html');

    // Log the URI as received by CloudFront and the new URI to be used to fetch from origin
    console.log("Old URI: " + olduri + " New URI: " + newuri);

    // Replace the received URI with the URI that includes the index page
    request.uri = newuri;
// %{endif}

  return request;

};
