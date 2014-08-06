// Agent
// -----------------------------------------

helper <- {
    function encode(str) {
        return http.urlencode({ s = str }).slice(2);
    }
}

class TwitterClient {
    consumerKey = null;
    consumerSecret = null;
    accessToken = null;
    accessSecret = null;
    
    baseUrl = "https://api.twitter.com/";
    
    constructor (_consumerKey, _consumerSecret, _accessToken, _accessSecret) {
        this.consumerKey = _consumerKey;
        this.consumerSecret = _consumerSecret;
        this.accessToken = _accessToken;
        this.accessSecret = _accessSecret;
    }
    
    function post_oauth1(postUrl, headers, post) {
        local time = time();
        local nonce = time;

        local parm_string = http.urlencode({ oauth_consumer_key = consumerKey });
        parm_string += "&" + http.urlencode({ oauth_nonce = nonce });
        parm_string += "&" + http.urlencode({ oauth_signature_method = "HMAC-SHA1" });
        parm_string += "&" + http.urlencode({ oauth_timestamp = time });
        parm_string += "&" + http.urlencode({ oauth_token = accessToken });
        parm_string += "&" + http.urlencode({ oauth_version = "1.0" });
        parm_string += "&" + http.urlencode({ status = post });
        
        local signature_string = "POST&" + helper.encode(postUrl) + "&" + helper.encode(parm_string)
        
        local key = format("%s&%s", helper.encode(consumerSecret), helper.encode(accessSecret));
        local sha1 = helper.encode(http.base64encode(http.hash.hmacsha1(signature_string, key)));
        
        local auth_header = "oauth_consumer_key=\""+consumerKey+"\", ";
        auth_header += "oauth_nonce=\""+nonce+"\", ";
        auth_header += "oauth_signature=\""+sha1+"\", ";
        auth_header += "oauth_signature_method=\""+"HMAC-SHA1"+"\", ";
        auth_header += "oauth_timestamp=\""+time+"\", ";
        auth_header += "oauth_token=\""+accessToken+"\", ";
        auth_header += "oauth_version=\"1.0\"";
        
        local headers = { 
            "Authorization": "OAuth " + auth_header,
        };
        
        local response = http.post(postUrl + "?status=" + helper.encode(post), headers, "").sendsync();
        return response
    }

    function Tweet(_status) {
        local postUrl = baseUrl + "1.1/statuses/update.json";
        local headers = { };
        
        local response = post_oauth1(postUrl, headers, _status)
        if (response && response.statuscode != 200) {
            server.log("Error updating_status tweet. HTTP Status Code " + response.statuscode);
            server.log(response.body);
            return null;
        } else {
            server.log("Tweet Successful!");
        }
    }
}


// Log the URLs we need
server.log("Turn LED On: " + http.agenturl() + "?bmp=1");
server.log("Turn LED Off: " + http.agenturl() + "?bpm=0");
 
function requestHandler(request, response) {
  try {
    // check if the user sent bmp as a query parameter
    if ("bmp" in request.query) {
      
      // if they did, and bmp=1.. set our variable to 1
      local bmp_string = request.query.bmp
      
      server.log("BMP rate recived : " + bmp_string);

      if (regexp("[0-9]+").match(bmp_string)) {

        // convert the bmp query parameter to an integer
        local bmp_rate = request.query.bmp.tointeger();
 
        // send "bmp" message to device, and send bmp_rate as the data
        device.send("bmp", bmp_rate); 

        server.log("BMP rate sent : " + bmp_rate);
      }
    }

    // send a response back saying everything was OK.
    device.on("senddata", function(data) {
        data.agenturl <- http.agenturl()
        local body = http.jsonencode(data);
        server.log(body);
        response.header("Content-Type", "application/json");
        response.send(200, body);
        
        twitter.Tweet(data.start_date+",blinked,"+data.delta_seconds+" sec,"+data.imp_id+","+http.agenturl());
        
    });
  
      
  } catch (ex) {
    response.send(500, "Internal Server Error: " + ex);
  }
}
 
// register the HTTP handler
http.onrequest(requestHandler);


// on connectoion

_CONSUMER_KEY    <- "9y0EXJjT0JEplwPBrcjh0mh7v"
_CONSUMER_SECRET <- "qKDDt0mVb2kurj3owS3d1AzVknJ1Lo65bCJnkPFFKD9y97xmJl"
_ACCESS_TOKEN    <- "2707764746-aoJDCG6JrQzxa5UHOzfiILnDHRLhW1hlC350fv8"
_ACCESS_SECRET   <- "mFhkR9vi17E3fg9p2HmQghqUsOcKFosPa3HEstXZuwXbB"

twitter <- TwitterClient(_CONSUMER_KEY, _CONSUMER_SECRET, _ACCESS_TOKEN, _ACCESS_SECRET);


// twitter.Tweet("Tweeting with the new @electricimp hash functionality.");
device.on("impid", function(imp_id){
  local t0 = date(time(), 'u');
  local d0 = t0.year+"-"+t0.month+"-"+t0.day+" "+t0.hour+":"+t0.min+":"+t0.sec;
  server.log(d0+",connected,"+imp_id+","+http.agenturl());
  twitter.Tweet(d0+",connected,"+imp_id+","+http.agenturl());
});

// device.ondisconnect(function{
//   local t0 = date(time(), 'u');
//   local d0 = t0.year+"-"+t0.month+"-"+t0.day+" "+t0.hour+":"+t0.min+":"+t0.sec;
//   server.log(d0+",disconnected,"+http.agenturl())
// });
