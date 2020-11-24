/**
* Name: Assignment3 Task2
* Author:Adithya and Shounak
* Description: Group 24
*/

model Task2 
 
global
{
    list<point> stagePositions <- [{15, 15}, {85, 15}, {15, 85},{85, 85}];
    list<rgb> stageColors <- [#black, #red, #purple, #blue];
   	int stage1_people <-0;
   	int stage2_people <-0;
   	int stage3_people <-0;
   	int stage4_people <-0;
    init {
        create Guest number: 4 {
           location <- {rnd(100), rnd(100)};
        }
        int counter <- 0;
        create Stage number: 4 {
            location <- stagePositions[counter];
            color <- stageColors[counter];
            counter <- counter + 1;
        }
       
    }
   
}
 
species Stage skills:[fipa]  {
	
	list<float> myValues <- [];
	rgb color;
	
	init {
		loop times: 6 {
			myValues << rnd(100.0)/100.0;
		}
	}
	
	reflex reAssignValues when: time mod 10 = 0 {
		myValues <- [];
		stage1_people<-0;
		stage2_people<-0;
		stage3_people<-0;
		stage4_people<-0;
		
		loop times: 6 {
			myValues << rnd(100.0)/100.0;
		}
	}
	
	reflex sendValues when: !empty(informs) 
	{
		write name + ": Guests are asking for my values so I'm sending them!";
		Guest sender;
		loop msg over: informs {
			sender <- msg.sender;
			do inform with:(message: msg, contents: [myValues]);
		}
		informs <- [];
	}

    aspect default
    {
        draw square(6) at: location color: color;
    }

 
}
 
species Guest skills:[moving, fipa] {
    list<float> myValues <- [];
    float mySpeed <- 0.0;
    point target <- nil;
    bool valuesChanged <- false;
    list<list<float>> stageValues <- [];
    list<float> utilityPerStage <- [0.0, 0.0, 0.0, 0.0];
    list<rgb> stageColors <- [];
    rgb color <- nil;
	int crowd <-rnd(1);
	//int crowd<-1;
	int t<-1;
    init {
		loop times: 6 {
			myValues << rnd(100.0)/100.0;
		}
		mySpeed <- rnd(3.0, 6.0);
    }
   
    reflex moveToTarget when: target != nil {
        do goto target:target speed: mySpeed;
    }
    
    
    //request stage values every interval
    reflex getStageInformation when: time mod 10 = 0 {
    	stageValues <- [];
        do start_conversation with:(to: list(Stage), protocol: 'fipa-request', performative: 'inform', contents: ['Send Values']);
        write name + ": I want to know the stage attribute values!";       
     }
     
     reflex findTheMostAppropriateStage when: valuesChanged {
        valuesChanged <- false;
        utilityPerStage <- [0.0, 0.0, 0.0, 0.0];
        loop stageIndex from: 0 to: length(Stage) - 1 
        {
            loop valueIndex from: 0 to: length(stageValues) - 1 
            {
                list<float> currentStageValues <- stageValues[stageIndex];
                
                if(stageIndex=0)
                {
                	utilityPerStage[stageIndex] <- utilityPerStage[stageIndex] + (currentStageValues[valueIndex] * myValues[valueIndex]);
                	if(crowd=1)
                	{
                		utilityPerStage[stageIndex]<-utilityPerStage[stageIndex]+stage1_people/(stage1_people+stage2_people+stage3_people+stage4_people+t);
                	}
                	if(crowd=0)
                	{
                		utilityPerStage[stageIndex]<-1+utilityPerStage[stageIndex]-stage1_people/(stage1_people+stage2_people+stage3_people+stage4_people+t);
                			
                	}
                }
                if(stageIndex=1)
                {
                	utilityPerStage[stageIndex] <- utilityPerStage[stageIndex] + (currentStageValues[valueIndex] * myValues[valueIndex]);
                	if(crowd=1)
                	{
                		utilityPerStage[stageIndex]<-utilityPerStage[stageIndex]+stage2_people/(stage1_people+stage2_people+stage3_people+stage4_people+t);
                	}
                	if(crowd=0)
                	{
                		utilityPerStage[stageIndex]<-1+utilityPerStage[stageIndex]-stage2_people/(stage1_people+stage2_people+stage3_people+stage4_people+t);
                			
                	}
                }
                
                if(stageIndex=2)
                {
                	utilityPerStage[stageIndex] <- utilityPerStage[stageIndex] + (currentStageValues[valueIndex] * myValues[valueIndex]);
                	if(crowd=1)
                	{
                		utilityPerStage[stageIndex]<-utilityPerStage[stageIndex]+stage3_people/(stage1_people+stage2_people+stage3_people+stage4_people+t);
                	}
                	if(crowd=0)
                	{
                		utilityPerStage[stageIndex]<-1+utilityPerStage[stageIndex]-stage3_people/(stage1_people+stage2_people+stage3_people+stage4_people+t);
                			
                	}
                }
                if(stageIndex=3)
                {
                	utilityPerStage[stageIndex] <- utilityPerStage[stageIndex] + (currentStageValues[valueIndex] * myValues[valueIndex]);
                	if(crowd=1)
                	{
                		utilityPerStage[stageIndex]<-utilityPerStage[stageIndex]+stage4_people/(stage1_people+stage2_people+stage3_people+stage4_people+t);
                	}
                	if(crowd=0)
                	{
                		utilityPerStage[stageIndex]<-1+utilityPerStage[stageIndex]-stage4_people/(stage1_people+stage2_people+stage3_people+stage4_people+t);
                			
                	}
                }
            }
            stageColors << Stage[stageIndex].color;
        }
       
       	// choose max utility
        float maxValue <- max(utilityPerStage);
        write utilityPerStage;
        write maxValue;
        int maxIndex <- 0;       
        loop currentUtilityIndex from:0 to: length(utilityPerStage) - 1 {
        	if(maxValue = utilityPerStage[currentUtilityIndex]) {
        		maxIndex <- currentUtilityIndex;
        	}
        }
        write name + ": found my match! going to stage at " + target + " now.";
        target <- stagePositions[maxIndex];
        color <- stageColors[maxIndex];
        if(maxIndex = 0)
        {
        	stage1_people<-stage1_people+1;
        }
        else if(maxIndex = 1)
        {
        	stage2_people<-stage2_people+1;
        }
        else if(maxIndex = 2)
        {
        	stage3_people<-stage3_people+1;
        }
        else if(maxIndex = 3)
        {
        	stage4_people<-stage4_people+1;
        }
        
     }
     
     reflex recieveValues when: (!empty(informs)) {
     	loop msg over: informs {
            stageValues << list(msg.contents)[0];
        }
        valuesChanged <- true;
        informs <- [];
     }
     
     aspect default {
        draw sphere(2) at: location color: color;
    }
   
}
 
experiment main type: gui
{
   
    output
    {
        display map type: opengl
        {
            species Guest;
            species Stage;
        }
    }
}