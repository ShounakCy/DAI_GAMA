///***
//* Name: Festival
//* Author: Adithya and Shounak
//* Description: Simualating a festival with bars, restaurants 
//* and guests that find the directions to the stores via an information center
//***/
//
model Festival

global {
	int dist_wm<-0;
	int dist_wom<-0;
	
	//int no_guests <- 4;
	//int no_guests_mem <- 7; 
	int no_bad_guests <- 10;
	//int distance_travelled <- 0;
	int guest_speed <- 2;
	int bad_speed <- 3;
	int guard_speed <- 5;
	
	point bad_guest_loc;
	bool bad_guest <- false;
	int threshold <- 100;
	bool security_alert <- false;
	
	int displacement <- 0;
	int displacement_mem <- 0;
	
	init {
		
		seed <- 10.0;
		bool alternateFlag;
		
		create FestivalGuest number: 20 {
			location <- {rnd(100), rnd(100)};
		}
		
		create Store number: 4 {
			location <- {rnd(100), rnd(100)};
			// blue: bar, red: restaurant
			if(alternateFlag) {
				color <- #blue;
				bar <- true;
				restaurant <- false;
				alternateFlag <- false;
			} else {
				color <- #red; 
				bar <- false;
				restaurant <- true;
				alternateFlag <- true;
			}
		}
		
		create InformationCenter number: 1 {
			location <- {50, 50};
		}
		create security_guard number: 1
		{
			location <- {60,60};
			targetpoint <- {rnd(100), rnd(100)};
			security_alert <- false;
		}
		create baddy_guest number: no_bad_guests
		{
			location <- {rnd(10), rnd(100)};
			targetpoint <- {rnd(100), rnd (100)};
			
			
		}
		
		
		
	}
}

species Store {	
	bool bar <- false;
	bool restaurant <- false;
	rgb color <- #white;
	
	aspect default {
		draw cube(8) at: location color: color; 
	}
	
}

species InformationCenter {
	list<Store> restaurants <- nil;
	list<Store> bars <- nil;
	
	init {
		ask Store {
			if(self.bar) {
				myself.bars << self;
			} else if(self.restaurant) {
				myself.restaurants << self;
				write myself.restaurants;
			}
		}
	}
	
	aspect default {
		draw pyramid(15) at: location color: #black;
	}
}

species FestivalGuest skills: [moving] {
	
	int thirsty <- rnd(1000);
	int hungry <- rnd(1000);
	point informationCenterLocation <- {50, 50};
	rgb color <- nil;
	point targetPoint <- nil;
	Store targetStore <- nil;
	Store prevstore <- nil;
	int ran<-69;
	int flag<-0;
	int flag2<-0;
	int flag_m<-0;
	bool report <- false;
	baddy_guest baddy;
	point bad_guest_loc;
	bool speak <- true;
	bool ishungry <- false;
	bool isthirsty <- false;
	

	bool alternateFlag;
	

	reflex beIdle when: targetPoint = nil and thirsty < 500 and hungry < 500 and !report{
		
		
			//write " I'm wandering";
			do wander;
		
	}
	
	reflex increaseValues when: (thirsty < 500 or hungry < 500) and !report
	{
		if (alternateFlag) {
			thirsty <- thirsty + 3;
			alternateFlag <- false;
		} else {
			hungry <- hungry + 3;
			alternateFlag <- true;
		}
	}
	
	reflex goToInformationCenter when: (hungry >= 500 or thirsty >= 500) and targetStore = nil and !report
	{
		flag<-0;
		ran <- rnd(2);

		if(ran=2 and prevstore!= nil)
		{
			targetStore<-prevstore;
		}
		if(ran=1 or prevstore= nil)
		{
		write 'going to information center';
		do goto target:informationCenterLocation;
		ask FestivalGuest at_distance 1 {
			
			if(self.prevstore!=nil)
			{
				write "human help";
				do goto target:self.prevstore;
				myself.color <- #pink;
				flag<-1;
			}
			}
			
			if (flag=0)	{
			ask InformationCenter at_distance 2	{	
						
				if (myself.thirsty >= 500)	{
					int i <- rnd(length(self.restaurants) - 1);
					myself.targetStore <- self.restaurants[i];
					write "I am hungry";
					//write myself.targetStore;
					myself.color <- #red;
				} else	{
					int i <- rnd(length(self.bars) - 1);
					myself.targetStore <- self.bars[i];
					write "I am thirsty";
					myself.color <- #blue;
				}
				}
			
			}

		}
	}
	
		
	reflex goToStore when: (targetStore != nil) {
		write 'going to Store';
		
			do goto target:targetStore;
			if(flag=0)
			{
				dist_wom<-dist_wom+1;
			}
			else 
			{
				dist_wm<-dist_wm+1;
			}
			
		ask Store at_distance 2 {
			if (myself.thirsty >= 500) {
				write "Thirst is quenched";
				myself.thirsty <- 0;
				
			} else {
				write "Hunger is met";
				myself.hungry <- 0;
			}
		}
		
		if (thirsty < 500 and hungry < 500) {
			targetPoint <- nil;
			prevstore <- targetStore;
			targetStore <- nil;
			color <- #green;
		}
	}
	
	reflex bad_alert when: bad_guest{
  		ask(baddy_guest){
  			if (myself.location distance_to(self.location) < 4){
  				write "I have found a Bad guy.";
  				myself.baddy <- self;
  				myself.report <- true;
  			}
	}
	}
		reflex report when: self.report and bad_guest{
  		point guard_position;
  		self.color <- #green;
  		
  		ask(security_guard){
  			guard_position <- self.location;
  		}
  		
  		do goto target: guard_position speed: guest_speed;
  		
  		if(self.location = guard_position){
  			ask(security_guard){
  				if( !(myself.baddy in self.targets) ) {
  					add myself.baddy to: self.targets;
  					write "Guard Informed";
  					security_alert <- true;
  					myself.report <- false;
  				} 
  				else {
  					write "Already informed.";
  					myself.report <- false;
  				}
  			}
  			report <- false;
  		}
  	}
	
	
	aspect default {
		draw sphere(2) at: location color: color;
	}
	

}


species baddy_guest skills: [moving]{
	aspect default {
		draw sphere(1) color: color lighted: bool(1);
	}
	
	rgb color <- #purple;
	point targetpoint;
	
	bool active <- false;
	bool speak <- true;
	bool chosen <- false;
	
	
	
	int bad_level <- 0;
	int mess <- rnd(1,5);
	
	int thirst ;
	int hunger ;

	
	
	
	
	reflex move when: !active{
		
		self.bad_level <- self.bad_level + self.mess;
		do wander ;
	}
	reflex movearound when: (thirst<500 and hunger<500)
	{
		do goto target: targetpoint speed: guest_speed;
		displacement <- displacement + 1;
		if (location distance_to(targetpoint) < guest_speed)
		{
			targetpoint <- {rnd(100), rnd(100)};
		}
	}
	

	reflex bad_begin when: (self.bad_level > threshold) and !active and !bad_guest{
		bad_guest <- true;
		active <- true;
		self.color <- #yellow;
		write self.name + " : I am bad !!!";
		//bad_guest_loc <- self.location;
	}
	
	reflex messing when: active{
		if !chosen{
			
			
				do wander speed: bad_speed;
			}
		
		else if chosen {
			do goto target:targetpoint speed: bad_speed;
			if (self.location = targetpoint){
				chosen <- false;
			}
		}
	}
			
}

species security_guard skills: [moving] {
	rgb color <- #black;
	point targetpoint;
	
	aspect default{
		draw cylinder(2,2) at: location color: color;
	}
	
	list<baddy_guest> targets <- [];

	reflex take_out when: security_alert{
		
		if (self.targets != []){	
			point target <- self.targets[0].location;
			do goto target: target speed: 5.0;
			if (self.location distance_to(target) < 2){
				ask (baddy_guest){
					if (length(myself.targets) > 0 and self = myself.targets[0]){
						write "Removed";
						//write "Total Distance: " + distance_travelled;
						remove first(myself.targets) from: myself.targets;
						do die;
					}
				}
			}
		}
		else {
			ask(FestivalGuest){
				self.report <- false;
			}
			bad_guest <- false;
			security_alert <- false;
			write "Baddy guest already addressed.";
		}
	}
	
	reflex at_base when: security_alert = false{
		do goto target: {80,80} speed: 5.0;
	}
}


experiment main type: gui {
	output {
		display map type: opengl 
		{
			species FestivalGuest;
			species Store;
			species InformationCenter;
			species security_guard;
			species baddy_guest;
			
		}
				display chart
		{
			chart "Agent displacements"
			{
				data "Agents with memory" value: dist_wm  color: #green;
				data "Agents without memory" value: dist_wom color: #red;
			}
		}
	}
}