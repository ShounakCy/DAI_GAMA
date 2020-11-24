///***
//* Name: Festival
//* Author: Adithya and Shounak
//* 
//***/
//
model Festival

global {
		int dist_wm<-0;
	int dist_wom<-0;
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

	bool alternateFlag;
	
		
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
				myself.thirsty <- 0;
			} else {
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
	
	
	reflex beIdle when: targetPoint = nil and thirsty < 500 and hungry < 500 {
		write 'being idle';
		color <- #green;
		do wander;
		
	}

	
	reflex goToInformationCenter when: (hungry >= 500 or thirsty >= 500) and targetStore = nil {
		flag<-0;
		ran<-rnd(2);

		if(ran=2 and prevstore!= nil)
		{
			targetStore<-prevstore;
		}
		if(ran=1 or prevstore= nil)
		{
			write 'going to information center';
		do goto target:informationCenterLocation;
		ask FestivalGuest at_distance 40 {
			if(self.prevstore!=nil)
			{
				write "human help";
				do goto target:self.prevstore;
				flag<-1;
			}
		}
		if (flag=0)
		{
		ask InformationCenter at_distance 2 {			
			if (myself.thirsty >= 500) {
				int i <- rnd(length(self.restaurants) - 1);
				myself.targetStore <- self.restaurants[i];
				write myself.targetStore;
				myself.color <- #red;
			} else {
				int i <- rnd(length(self.bars) - 1);
				myself.targetStore <- self.bars[i];
				myself.color <- #blue;
			}
		}
		
		}

	}
}

	reflex increaseValues when: thirsty < 500 or hungry < 500 {
		if (alternateFlag) {
			thirsty <- thirsty + 3;
			alternateFlag <- false;
		} else {
			hungry <- hungry + 3;
			alternateFlag <- true;
		}
	}
	
	aspect default {
		draw sphere(2) at: location color: color;
	}
	

}
experiment main type: gui {
	output {
		display map type: opengl 
		{
			species FestivalGuest;
			species Store;
			species InformationCenter;
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
