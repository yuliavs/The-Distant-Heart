// Agent
// -----------------------------------------

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
    response.send(200, "OK");
  } catch (ex) {
    response.send(500, "Internal Server Error: " + ex);
  }
}
 
// register the HTTP handler
http.onrequest(requestHandler);

// // evaluate regex
// local pattern = regexp(".+\\.txt$")
// local a = pattern.match("Document.txt")
// server.log(a);
