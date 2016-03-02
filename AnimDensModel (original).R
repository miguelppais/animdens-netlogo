#Simulation model: AnimDens
#By: Christine Ward-Paige, December 2009. 

#This is a function that simulates divers counting fish while deploying the belt-transect and stationary-
#point-count underwater visual census techniques. The model assumes an area that is featureless and flat. The depth 
#can be changed (default is 1m). For each simulation, the divers start in the middle and face in the same 
#direction. At each time step (which is set by the user) divers count the number of fish they can see based
#on the direction the diver is facing, the visibility distance (set by the user) and the angle of which the 
#diver can see at a given time step (set by the user). The fish move at a speed specified by the user, and 
#travel in a direction that is restricted (selected angle is set by the user) based on the previous direction. 
#Fish that reach the boundaries of the area are able to leave and come back in (not reflected). Divers do
#not recount fish. 

#There are 2 steps to this simulation:
#1. Defines the function. Here, defaults and other factors can be set. 
#2. Set the parameters. Most parameters have been set up to be changed easily and run across a range of 
#values. 


#############DEFINE THE FUNCTION###############
shark.simulation <- function(
	visib.length=13,
	stationary.radius=7.5, 
	transect.width=4, 
	B0=60, 
	B1=0,
	sample.area.x=840, 
	sample.area.y=840, 
	sample.total.area= (sample.area.x*sample.area.y), 
	sample.area.z=1,       
	time.step=2, 
	transect.diver.mean.speed=4/60, 
	transect.diver.range.speed=0, 
      transect.diver.spread.speed=5, 
	shark.mean.speed=0, 
	shark.range.speed=0,  
      shark.spread.speed=0.1,
	numb.sharks=10,
	nsim = 1,
	no.sec=60,
	stationary.vis.angle=80,
	shark.dir.angle=45
)

{
	number.seen.transect<- rep(0,nsim)
	number.seen.stationary<-rep(0,nsim)

for (j in 1:nsim)
{
plot (sample.area.x/2,sample.area.y/2,xlim=c(0,sample.area.x),ylim=c(0,sample.area.y))
abline(h=sample.area.x/2,v=sample.area.x/2)

#PLACE THE DIVERS: randomly place 2 divers in the x and y coordinates, 1m above 0 in the z coordinate
	transect.diver.location.x<-sample.area.x/2
	transect.diver.location.y<-sample.area.y/2
	transect.diver.location.z<-1
	stationary.diver.location.x<-transect.diver.location.x
	stationary.diver.location.y<-transect.diver.location.y
	stationary.diver.location.z<-transect.diver.location.z

#ORIENT THE DIVERS: start all divers in the same direction 	
	transect.diver.direction<-90
	stationary.diver.direction<-transect.diver.direction		

#PLACE THE SHARKS: randomly place sharks in the sample area and return a list of all their locations
	simulate.shark.locations<-function(numb.sharks,sample.area.x,sample.area.y,sample.area.z)
	{
	x.shark<-runif(numb.sharks,0,sample.area.x) 
	y.shark<-runif(numb.sharks,0,sample.area.y)
	z.shark<-runif(numb.sharks,0,sample.area.z)
	return(list(x.shark=x.shark,y.shark=y.shark,z.shark=z.shark))
	}
	shark.locations.sim<-simulate.shark.locations(numb.sharks,sample.area.x,sample.area.y,sample.area.z)
	text(shark.locations.sim$x.shark,shark.locations.sim$y.shark, 1:numb.sharks)

#ORIENT THE SHARKS: randomly select a direction (0-360) that the sharks will face for time=0
	shark.direction.horiz<-runif(numb.sharks,0,360)

	vert.angle.sim<-rbeta(numb.sharks,5,5)
		#2. translate the mean to be between 4.5/60 and 5.5/60 instead of 0 and 1 (m/min to m/seconds)
		a=15
		b=165
		shark.direction.vert=a+vert.angle.sim*(b-a)


	#vectors to fill the shark sightings in as it run's through the loop
		transect.diver.sharks<-rep(0,numb.sharks)
		roving.diver.sharks<-rep(0,numb.sharks)
		stationary.diver.sharks<-rep(0,numb.sharks)

#COUNT THE SHARKS AT INITIAL TIME: 
	#1. Distance between the sharks and divers: subtract the distance in x,y,z coordinates of divers from sharks :	sqrt((xs-xr)^2+(ys-yr)^2+(zs-zr)^2)
		transect.diver.shark.distance<- sqrt((shark.locations.sim$x.shark-transect.diver.location.x)^2+(shark.locations.sim$y.shark-transect.diver.location.y)^2+(shark.locations.sim$z.shark-transect.diver.location.z)^2)
		stationary.diver.shark.distance<- sqrt((shark.locations.sim$x.shark-stationary.diver.location.x)^2+(shark.locations.sim$y.shark-stationary.diver.location.y)^2+(shark.locations.sim$z.shark-stationary.diver.location.z)^2)

	#2. if the sharks aren't within max visibility of the diver then they are zero
			transect.shark.distance.detection<-ifelse (transect.diver.shark.distance<= visib.length, 1, 0) #selecting 1 if close enough to roving diver if not then 0
			stationary.shark.distance.detection<-ifelse (stationary.diver.shark.distance<= visib.length, 1, 0) #selecting 1 if close enough to roving diver if not then 0

	#3. if they are close enough to be seen then we need to deal with angles to see if they see them: atan2((ys-yd),(xs-xd))
		#a) find the angle b/w the diver and shark: gives positive angles and is positive when the y for the shark is greater than the y of the diver

			transect.shark.box.detection<-ifelse(shark.locations.sim$y.shark-transect.diver.location.y >=0 & shark.locations.sim$y.shark-transect.diver.location.y <= visib.length & abs(shark.locations.sim$x.shark-transect.diver.location.x)<.5*transect.width,1,0)
			transect.shark.vert.angle<-acos((shark.locations.sim$z.shark-transect.diver.location.z)/transect.diver.shark.distance)/pi*180 
			transect.shark.vert.detection<-ifelse(transect.shark.vert.angle<=40,0,1)

			stationary.shark.angle<- atan2((shark.locations.sim$y.shark-stationary.diver.location.y),(shark.locations.sim$x.shark-stationary.diver.location.x))/pi*180 
			stationary.shark.angle<- ifelse(shark.locations.sim$y.shark>stationary.diver.location.y,stationary.shark.angle,stationary.shark.angle+360)%%360
			stationary.shark.angle.detection<-ifelse(stationary.shark.angle<=(stationary.diver.direction+stationary.vis.angle)%%360 | stationary.shark.angle>=(stationary.diver.direction-stationary.vis.angle)%%360,1,0)
			stationary.shark.vert.angle<-acos((shark.locations.sim$z.shark-stationary.diver.location.z)/stationary.diver.shark.distance)/pi*180 
			stationary.shark.vert.detection<-ifelse(stationary.shark.vert.angle<=40,0,1)

		#b) now deal with the orientation of the diver relative to the shark
			transect.shark.detection<-transect.shark.box.detection*transect.shark.distance.detection*transect.shark.vert.detection
			stationary.shark.detection<-stationary.shark.angle.detection*stationary.shark.distance.detection*stationary.shark.vert.detection

	transect.diver.sharks<-transect.diver.sharks+transect.shark.detection
	stationary.diver.sharks<-stationary.diver.sharks+stationary.shark.detection


#LOOP 
	for (i in 1:no.sec) 

{	

#MOVE THE DIVERS
	#Transect Diver: straight ahead
		#1.simulate 1 random number from the beta distribution with parameter transect.diver.spread.speed
			speed.sim<-rbeta(1,transect.diver.spread.speed,transect.diver.spread.speed)
		#2. translate the mean to be between 4.5/60 and 5.5/60 instead of 0 and 1 (m/min to m/seconds)
			a=transect.diver.mean.speed-transect.diver.range.speed
			b=transect.diver.mean.speed+transect.diver.range.speed
			transect.diver.real.speed=a+speed.sim*(b-a)
		#3. now take direction (from above) and speed and move the diver along
			#update location for new time step by add new direction to old
		transect.diver.location.x<-transect.diver.location.x+transect.diver.real.speed*cos(transect.diver.direction/360*2*pi)
		transect.diver.location.y<-transect.diver.location.y+transect.diver.real.speed*sin(transect.diver.direction/360*2*pi)
		transect.diver.location.z<-1
		points(transect.diver.location.x,transect.diver.location.y,pch='*')
	#Stationary Diver
		#stay in a single location and spin
		#move the diver 4 degrees for every 1 second
			stationary.diver.direction<-stationary.diver.direction+4 
			stationary.diver.direction<-stationary.diver.direction %% 360 #angles bigger than 360 #
			stationary.diver.direction<-ifelse(stationary.diver.direction <0,360+stationary.diver.direction,stationary.diver.direction) 

#MOVE THE SHARKS
		#a. randomly sample the angle within 'shark.dir.angle' degree around the shark where they will move in 1 second time step 
			shark.direction.horiz<-shark.direction.horiz+runif(numb.sharks,-(shark.dir.angle),shark.dir.angle)
			shark.direction.vert<-shark.direction.vert+runif(numb.sharks,-5,5)
			shark.direction.vert<-ifelse(shark.direction.vert>165,165,shark.direction.vert)
			shark.direction.vert<-ifelse(shark.direction.vert<15,15,shark.direction.vert)

		#b.simulate 1 random number from the beta distribution with parameter shark.spread.speed
			speed.sim<-rbeta(numb.sharks,shark.spread.speed,shark.spread.speed)

		#c. translate the mean to be between 4.5/60 and 5.5/60 instead of 0 and 1 (m/min to m/seconds)
			a=shark.mean.speed-shark.range.speed
			b=shark.mean.speed+shark.range.speed
			shark.real.speed=a+speed.sim*(b-a)
		#d. now take direction (from above) and speed and move the shark along
			#update location for new time step by add new direction to old
		
			shark.locations.sim$x.shark<-shark.locations.sim$x.shark+shark.real.speed*cos(shark.direction.horiz/180*pi)*sin(shark.direction.vert/180*pi)
			shark.locations.sim$y.shark<-shark.locations.sim$y.shark+shark.real.speed*sin(shark.direction.horiz/180*pi)*sin(shark.direction.vert/180*pi)

			shark.locations.sim$z.shark<-shark.locations.sim$z.shark+shark.real.speed*cos(shark.direction.vert/180*pi)

          	        shark.direction.vert<-ifelse(shark.locations.sim$z.shark>sample.area.z,runif(1,15,90),shark.direction.vert)
        		shark.locations.sim$z.shark<-ifelse(shark.locations.sim$z.shark>sample.area.z,sample.area.z,shark.locations.sim$z.shark)
			
         	        shark.direction.vert<-ifelse(shark.locations.sim$z.shark<0,runif(1,90,165),shark.direction.vert)
        		shark.locations.sim$z.shark<-ifelse(shark.locations.sim$z.shark<0,0,shark.locations.sim$z.shark)
						
                 	points(shark.locations.sim$x.shark,shark.locations.sim$y.shark,pch='x')


#AT EACH TIME STEP
	#a. Distance between the sharks and divers: subtract the distance in x,y,z coordinates of divers from sharks :	sqrt((xs-xr)^2+(ys-yr)^2+(zs-zr)^2)
			transect.diver.shark.distance<- sqrt((shark.locations.sim$x.shark-transect.diver.location.x)^2+(shark.locations.sim$y.shark-transect.diver.location.y)^2+(shark.locations.sim$z.shark-transect.diver.location.z)^2)
			stationary.diver.shark.distance<- sqrt((shark.locations.sim$x.shark-stationary.diver.location.x)^2+(shark.locations.sim$y.shark-stationary.diver.location.y)^2+(shark.locations.sim$z.shark-stationary.diver.location.z)^2)

	#b. if the sharks aren't within max visibility of the diver then they are zero
			transect.shark.distance.detection<-ifelse (transect.diver.shark.distance<= visib.length, 1, 0) #selecting 1 if close enough to roving diver if not then 0
			stationary.shark.distance.detection<-ifelse (stationary.diver.shark.distance<= visib.length, 1, 0) #selecting 1 if close enough to roving diver if not then 0

	#c. if they are close enough to be seen then we need to deal with angles to see if they see them: atan2((ys-yd),(xs-xd))
		#find the angle b/w the diver and shark: gives positive angles and is positive when the y for the shark is greater than the y of the diver

			transect.shark.box.detection<-ifelse(shark.locations.sim$y.shark-transect.diver.location.y >=0 & shark.locations.sim$y.shark-transect.diver.location.y <= visib.length & abs(shark.locations.sim$x.shark-transect.diver.location.x)<.5*transect.width,1,0)
			transect.shark.vert.angle<-acos((shark.locations.sim$z.shark-transect.diver.location.z)/transect.diver.shark.distance)/pi*180 
			transect.shark.vert.detection<-ifelse(transect.shark.vert.angle<=40,0,1)

			stationary.shark.angle<- atan2((shark.locations.sim$y.shark-stationary.diver.location.y),(shark.locations.sim$x.shark-stationary.diver.location.x))/pi*180 
			stationary.shark.angle<- ifelse(shark.locations.sim$y.shark>stationary.diver.location.y,stationary.shark.angle,stationary.shark.angle+360)%%360
			stationary.shark.angle.detection<-ifelse(stationary.shark.angle<=(stationary.diver.direction+stationary.vis.angle)%%360 | stationary.shark.angle>=(stationary.diver.direction-stationary.vis.angle)%%360,1,0)
			stationary.shark.vert.angle<-acos((shark.locations.sim$z.shark-stationary.diver.location.z)/stationary.diver.shark.distance)/pi*180 
			stationary.shark.vert.detection<-ifelse(stationary.shark.vert.angle<=40,0,1)

	#d. now deal with the orientation of the diver relative to the shark
			transect.shark.detection<-transect.shark.box.detection*transect.shark.distance.detection*transect.shark.vert.detection
			stationary.shark.detection<-stationary.shark.angle.detection*stationary.shark.distance.detection*stationary.shark.vert.detection


	#e. make a list of all the sharks seen at each time step
		transect.diver.sharks<-transect.diver.sharks+transect.shark.detection
		stationary.diver.sharks<-stationary.diver.sharks+stationary.shark.detection


}
	number.seen.transect[j]<-sum(ifelse(transect.diver.sharks>0,1,0))
	number.seen.stationary[j]<-sum(ifelse(stationary.diver.sharks>0,1,0))

}
return(c(number.seen.transect, number.seen.stationary))
}


################PART 2: VARY THE PARAMETERS####################
#Run shark.simulation function for a range of run times for a few different shark speeds

unq.density<-c(1)#,10,100,1000)#,10000,100000) #number of fish in samplearea 
unq.speed<-c(0)#,0.001,0.01,0.1,0.5,1,2,4) #m/sec
unq.transectwidth<- c(1)#,4,8,20) #m 
unq.transectspeed<- c(1/60)#,4/60,7/60)#m/min
unq.time<-c(1)#,300)#3600) #sec
unq.visib<-c(1)#,13,29,45) #m
unq.sharkangle<- c(1)#,22.5,45) #degrees

actual.area<-(840*840)
actual.density<-(unq.density/actual.area)

results.int<-c()

for (i in unq.density)
{
for (j in unq.speed) 
{
for (k in unq.time)
{
for (l in unq.visib)
{
for (m in unq.transectwidth)
{
for (n in unq.transectspeed)
{
for (o in unq.sharkangle)
{

res<- shark.simulation(shark.mean.speed=j, 
	numb.sharks=i,
	no.sec=k,
	visib.length=l,
	transect.width=m,
	transect.diver.mean.speed=n,
	shark.dir.angle=o
	)

results.int<-rbind(results.int,c(i,j,k,l,m,n,o,actual.area,actual.density,res)) 
}
}
}
}
}
}
}

results.int
############SAVE THE RESULTS
#results<- results.int
#save(results,file="TimeDensSpeed.save")
#q("yes")
#write.table(results, file="RangeA1.csv",row.names=TRUE,col.names=TRUE,sep=" ")



