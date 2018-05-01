# peote-event

Pure haxe eventhandling and time-scheduling.  
All relations between the objects that handle events are stored in dynamic linked lists.  

# How to use

Create a class that extends the PeoteEvent<PARAM> with a specific parametertype PARAM.  
The callback-function for recieving events must have 2 parameters,  
the event-number of type `Int` and some data of type `PARAM` (in this case `String`):
```
class GameObject extends PeoteEvent<String>
{
    public function new() { super(); }

	public function recieveEvent(event:Int, param:String ):Void 
	{
		trace( 'recieves event $event: $param' );
	}
}
```

Instanzes of that type are able to send and recieve events:
```
alice = new GameObject();
bob   = new GameObject();
```

Let an object listen to another object for an specific event number:
```
alice.listenEvent( bob, 1, alice.recieveEvent ); // alice ist listening to event 1 from bob
```

If `bob` is sending an event with that number, all objects that listen to it  
will call it's recieve-function with the additional string-parameter:
```
bob.sendEvent ( 1, "message from bob" ); // bob is send an event with number 1 and some string-data
```
in this case the `recieveEvent` function of object `alice` is called.




# PeoteEvents and the PeoteTimeslicer

The `PeoteTimeslicer` class works like a singlethreaded scheduler.  
It queues all `PeoteEvents` and runs the callbacks somwhat later in time.  
  
The first parameter defines the maximum delay-time in seconds for all time-events.  
The second parameter defines the precision of the scheduler in steps-per-seconds:
```
var timeslicer:PeoteTimeslicer<String> = new PeoteTimeslicer<String>(60, 10);
timeslicer.start();
```
Take care of these values, internally it will create a great ringbuffer with a  
size of `maxSeconds * stepsPerSecond + 1` to store all events related to a specific timestep.  
  

Use the `sendTimeEvent` method together with a running `timeslicer`-object to send the event after a `delay`:
```
b.sendTimeEvent ( 1, "message from b", timeslicer, 3.5 );
```
in this case the `recieveEvent` function of object `a` is called by the timeslicer `3.5` seconds later.  




# PeoteEvent API
```
sendEvent(event:Int, params:PARAM = null)
    sending an (numbered) event to all listeners
    params are optional

sendTimeEvent(event:Int, params:PARAM = null, timeslicer:PeoteTimeslicer<PARAM>, delay:Float = 0.0)
    sending an (numbered) event to all listeners after a delay-time
    params and delay are optional

listenEvent(sender:PeoteEvent<PARAM>, event:Int , callback:Int->PARAM->Void, checkEventExists:Bool = true)
    listen to an specific object for an (numbered) event
    if an event is recieved the callback function is called
	if checkEventExists is true, old listenings to that event will deleted before setting a new one
	
unlistenEvent(sender:PeoteEvent<PARAM>, event:Int)
    stops listening of a specific event from the sender-object

unlistenFrom(sender:PeoteEvent<PARAM>)
   stops listening of all events from the sender-object

unlistenAll()
    stops listening to all sender-objects

removeListener(listener:PeoteEvent<PARAM>)
    removes a specific listener-object

removeAllListener()
    removes all listener-objects
```



# Todo

- more timeslicer methods
- more samples and docs
- different optimization-methods and more performance tests
