// Device

// globals ----------------------------------

// max time the device would be lkinking 
TIME_SECONDS <- 10;

// set global led dimm factor
DIMM <- 0.5;

// set colors per pulse value
RGB_RANGE <- [
	{ min_bmp = 0  , rgb = [  0,  0,  0]},
	{ min_bmp = 10 , rgb = [100,100,100]},
	{ min_bmp = 40 , rgb = [140,140,140]},
	{ min_bmp = 80 , rgb = [180,180,180]},
	{ min_bmp = 100, rgb = [200,200,200]},
	{ min_bmp = 140, rgb = [240,240,240]},
];


// functions -------------------------------

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
	converts rgb value 0-255 to float 0.0-1.0
	*/
	local result = [0,0,0];
    for(local i=0;i<rgb.len();i+=1){
		result[i] = (rgb[i]/255.0) * DIMM; 
    };	
	return result
};

function blink(led_r,led_g,led_b,rgb_led_value){
	led_r.write(rgb_led_value[0]);
	led_g.write(rgb_led_value[1]);
	led_b.write(rgb_led_value[2]);
};




// setup -------------------------------

// create a global variabled called led, 
// and assign pin9 to it
local led_r = hardware.pin2;
local led_g = hardware.pin5;
local led_b = hardware.pin7;

// configure led to be a digital output
led_r.configure(PWM_OUT, 1.0/400.0, 0.0);
led_g.configure(PWM_OUT, 1.0/400.0, 0.0);
led_b.configure(PWM_OUT, 1.0/400.0, 0.0);


// buzzer
local buzzer = hardware.pin9;
buzzer.configure(DIGITAL_OUT)

// main -------------------------------

function main(bmp){

	// set values
	local rgb = get_rgb(bmp, RGB_RANGE);
	local rgb_led_value = rgb_to_float(rgb, DIMM);
	local time_start = hardware.millis()
	local time_end = time_start+(TIME_SECONDS*1000)
	local button_state = button.read()

	while((hardware.millis()<time_end)){
		
		// blink		
		blink(led_r,led_g,led_b,rgb_led_value)

		// wait
		imp.sleep(0.0001);

		// swichoff

		// wait

	};
	blink(led_r,led_g,led_b,[0,0,0]);

    // log
	server.log("BMP rate : "+bmp);
	server.log("LED dimm : "+DIMM);
	server.log("RGB vals : "+rgb[0]+","+rgb[1]+","+rgb[2]);
	server.log("RGB leds : "+rgb_led_value[0]+","+rgb_led_value[1]+","+rgb_led_value[2]);


};

// register a handler for "led" messages from the agent
agent.on("bmp", main);
server.log(button.read());