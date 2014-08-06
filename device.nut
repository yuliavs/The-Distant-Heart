// Device

// CONFIGURE GLOBAL SETTINGS -----------------

// max time the device would be lkinking 
ACTION_TIME_SECONDS <- 5;

// set global led dimm factor
DIMM <- 1.0;    // was 0.5

// set colors per pulse value
RGB_RANGE <- [
    { min_bmp = 0  , rgb = [  0,  0,  0]},
    { min_bmp = 30 , rgb = [80,0,50]},       // dark burgundy
    { min_bmp = 40 , rgb = [100,0,50]},     
    { min_bmp = 50 , rgb = [150,0,50]},        
    { min_bmp = 60 , rgb = [165,0,50]},      
    { min_bmp = 70 , rgb = [225,0,25]},            
    { min_bmp = 80 , rgb = [255,0,0]},       // red      
    { min_bmp = 90 , rgb = [255,50,0]},          
    { min_bmp = 100, rgb = [255,100,0]},       
    { min_bmp = 110, rgb = [255,150,0]},       
    { min_bmp = 120, rgb = [255,200,0]},     // yellow    
    { min_bmp = 130, rgb = [255,225,0]},          
    { min_bmp = 140, rgb = [255,255,0]},          
    { min_bmp = 150, rgb = [255,100,0]},          
    { min_bmp = 160, rgb = [255,255,255]},     // white   
];


// decleare lobal vars ---------------------
rgb             <- [0,0,0];
rgb_float       <- [0.0, 0.0, 0.0];
time_start      <- null;
time_end        <- null;
time_finished   <- null;
blink_second    <- null;
button_state    <- null;

// setup pins --------------------------------

// create a global RGB variable leds 
// and configure it to PWM output
led_r <- hardware.pin2;
led_g <- hardware.pin5;
led_b <- hardware.pin7;
led_r.configure(PWM_OUT, 1.0/400.0, 0.0);
led_g.configure(PWM_OUT, 1.0/400.0, 0.0);
led_b.configure(PWM_OUT, 1.0/400.0, 0.0);

// creat and configure button
button <- hardware.pin8;
button.configure(DIGITAL_IN_PULLUP);

// creat and configure buzzer
buzzer <- hardware.pin9;
buzzer.configure(PWM_OUT, 1.0/400.0, 0.0);


// functions -------------------------------

function _blink(rgb_value){
    /*
    Function blinks all 3 rgb leds
    Globals: 
        led_r
        led_g
        led_b
        rgb_float
    */
    led_r.write(rgb_value[0]);
    led_g.write(rgb_value[1]);
    led_b.write(rgb_value[2]);
};

function blink_sequence(rgb_value, blink_second){
    /*
    single hart beat sequence
    */
    _blink(rgb_value);
    imp.sleep(0.1*blink_second);
    _blink([ 0, 0, 0]);
    imp.sleep(0.1*blink_second);
    _blink(rgb_value);
    imp.sleep(0.2*blink_second);
    _blink([ 0, 0, 0]);
    imp.sleep(0.8*blink_second);

}

function buzz_sequence(buzz_t){
    buzzer.write(1.0);
    imp.sleep(0.3*buzz_t);
    buzzer.write(0);
    imp.sleep(0.2*buzz_t);
    buzzer.write(1.0);
    imp.sleep(0.5*buzz_t);
    buzzer.write(0);
};


function get_rgb(bmp, RGB_RANGE){
    /*
    Function iterates over rgb_range list
    assigning rgb value if greather than
    min_bmp
    */
    local rgb;
    for(local i=0;i<RGB_RANGE.len();i+=1){
        if(RGB_RANGE[i].min_bmp<=bmp){
            rgb = RGB_RANGE[i].rgb;
        };
    };
    return rgb
};

function rgb_to_float(rgb, DIMM){
    /*
    converts rgb value 0-255 to float 0.0-1.0,
    and adds dimm factor
    */
    local result = [0,0,0];
    for(local i=0;i<rgb.len();i+=1){
        result[i] = (rgb[i]/255.0) * DIMM; 
    };  
    return result
};



// main -------------------------------

function main(bmp){

    // set values
    local t0 = date(time(), 'u')  // timestamp
    rgb          = get_rgb(bmp, RGB_RANGE);
    rgb_float    = rgb_to_float(rgb, DIMM);
    time_start   = hardware.millis()
    time_end     = time_start+(ACTION_TIME_SECONDS*1000)
    button_state = button.read();
    blink_second = 60.0/bmp;

    
    buzz_sequence(0.7);
    
    while(hardware.millis()<time_end && button.read()==button_state){
        
        // blink        
        blink_sequence(rgb_float, blink_second)

    };
    time_finished = hardware.millis()
    _blink([0,0,0]);

    // log
    server.log("BMP rate : "+bmp);
    server.log("LED dimm : "+DIMM);
    server.log("RGB vals : "+rgb[0]+","+rgb[1]+","+rgb[2]);
    server.log("RGB leds : "+rgb_float[0]+","+rgb_float[1]+","+rgb_float[2]);
    server.log("blink s. : "+blink_second);
    server.log("action t : "+ACTION_TIME_SECONDS);
    
    // data
    
    local t1 = date(time(), 'u')  // timestamp

    local data = {};
    data.start_timestamp <- t0.time
    data.start_date <- t0.year+"-"+t0.month+"-"+t0.day+" "+t0.hour+":"+t0.min+":"+t0.sec
    // data.end_timestamp <- t1.time
    // data.end_date <- t1.year+"-"+t1.month+"-"+t1.day+" "+t1.hour+":"+t1.min+":"+t1.sec
    data.delta_seconds <- t1.time - t0.time
    data.rgb <- rgb
    data.bmp <- bmp
    data.wifi_BSSID <- imp.getbssid()
    data.imp_id <- hardware.getdeviceid()
    data.wifi_signal_strenght <- imp.rssi()

    // encode data and log
    agent.send("senddata", data);

};

// register connection imp-id and wifi-id
agent.send("impid",hardware.getimpeeid()+","+imp.getbssid())

// register a handler for "led" messages from the agent
agent.on("bmp", main);