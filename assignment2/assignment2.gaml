/***
* Name: Shounak and Adithya
* Author: Group 24
***/

model Auction

global {
       init {
         
        create participant number: 10 {
           location <- {rnd(100), rnd(100)};
           color <- #blue;
           
        }
     
        create Auctioneer number: 2 {
           	location <- {rnd(100), rnd(100)};
           	color <- #red;
           	
        }
        
       
	
    }
            //int type_of_auction<-rnd(2);  
       
    
}

species Auctioneer skills:[fipa] {
	
    int type_of_auction; 
	bool acutionStarted <- false;
    bool myTurn <- true;
    int minimumPrice <- 1000 + rnd(500, 1000);
    int startPrice <- minimumPrice + rnd(1000,2000);
    int currentPrice <- startPrice;
    
    participant winner <- nil;
    list<participant> potentialBuyers <- [];
    bool itemSold <- false;
    
    init {
    	ask participant {
    		myself.potentialBuyers << self;
    	}
    }
     reflex initiateAuction when: !acutionStarted and !itemSold
     {	type_of_auction <- 2;
     	
        write "Auction Starting Everyone!!!"+type_of_auction;
        do start_conversation (to: list(potentialBuyers), protocol: 'fipa-request', performative: 'inform', contents: ['Start']);
        acutionStarted <- true;
    }

    
    reflex sendProposals when: acutionStarted and myTurn and !empty(potentialBuyers) and !itemSold
    {
    	write name + " Going for... " + currentPrice + "!!!";
    	if(type_of_auction=2)
    	{
    		write "submit sealed bids";
    	}
    	do start_conversation with:(to: list(potentialBuyers), protocol: 'fipa-contract-net', performative: 'cfp', contents: [currentPrice]);
    	myTurn <- false;
    }
    reflex receieveProposes when: !empty(proposes) and winner = nil 
    {	int max_pris<-0;
    	int win_pris<-0;
    	int max2_pris<-0;
    	
    	bool foundWinner <- false;
    	
    	loop p over: proposes {

			if(list(p.contents)[0] = 'accept') {
				foundWinner <- true;
				itemSold <- true;
				winner <- p.sender;
				break;
			}
			else if(list(p.contents)[0] = 'sealed')
			
			{	max_pris<-0;
				int type_seal<-rnd(2);
				loop p over: proposes {
					//write p.contents;
					if(list(p.contents)[0] = 'sealed')
					{	
						if(int(list(p.contents)[1])>max_pris)
						{
						
						max2_pris<-win_pris;
						
						max_pris<-int(list(p.contents)[1]);
						win_pris<-max_pris;	
						write max_pris;
						
						}
					}
				}
					foundWinner <- true;
						itemSold <- true;
						//winner <- p.sender;
			}
			
		}
		if(foundWinner) {
	        	acutionStarted <- false;
	        	if(type_of_auction=1)
	        	{
	            write ' Found a winner! '+  ' won for '+ currentPrice;
	            
	            }
	            else 
	            {int type_sealed <- rnd(1,2);
	            	if(type_sealed=1)
	            	{
	           		write ' Found a winner sealed auction!  won for '+ win_pris;
	           		
	           		}
	           		else
	           		{
	           		write ' Found a winner Vickerey auction!  won for '+ max2_pris;	
	           		}
	           		
	            	
	            }
		} else 
		{
			write name + " No one likes this price, let's drop it!";
			if (currentPrice <= minimumPrice) {
				write "Opps price already too low, auction is over, you're all too cheap!";
				acutionStarted <- false;
				itemSold <- true;
			} else {
				currentPrice <- currentPrice - rnd(50,200);
	    		myTurn <- true;
			}
		}
    	proposes <- [];
    }
    
    aspect default 
	{
        draw pyramid(8) at: location color: #black;
    }
}

species participant skills:[fipa] 
{
	
    int type_of_auction;
	rgb color <- #blue;   
    
    int currentPrice <- 0;
    int decision<- rnd(2);
    reflex readOffers when: (!empty(cfps)) {
    	ask Auctioneer {
    		myself.type_of_auction <- self.type_of_auction;
    	}
    	int willingToPay <- rnd(1500,2500);
    	message offerFromAuctioneer <- cfps[0];
    	
        int offeredPrice <- int(list(offerFromAuctioneer.contents)[0]);
     	if(decision=1 and type_of_auction=2) 
        {
            write name + "Sealed bid";
            color <- #green;
            do propose with: (message: offerFromAuctioneer, contents: ['sealed',willingToPay]);
        }
        else if(willingToPay >= offeredPrice and decision=1 and type_of_auction=1) 
        {
            write name + ": I accept!!!";
            color <- #green;
            do propose with: (message: offerFromAuctioneer, contents: ['accept', offeredPrice]);
        } 
        else 
        {
        	if(decision =2)
        	{
        		 write name + ": No Thanks!" +"Not Interested";
           	
        	}
        	else if(willingToPay <= offeredPrice)
        	{
            write name + ": No Thanks!" +"Too High";
            
            }
            color <- #red;
            do propose with: (message: offerFromAuctioneer, contents: ['reject']);
        }
    }    	
		    
    	aspect default 
    	{
        	draw sphere(2) at: location color: color;
    	}
    	
}

experiment main type: gui {
      
    output {
        display map type: opengl {
            species participant;
            species Auctioneer;
        }
    }
 }