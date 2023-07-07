# peote-event

Pure [Haxe](http://haxe.org) eventhandling and time-scheduling.  
All relations between the objects that handle events are stored in linked lists.  


## Installation:
```
haxelib git peote-event https://github.com/maitag/peote-event
```


## How to use

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




## PeoteEvents and the PeoteTimeslicer

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
bob.sendTimeEvent ( 1, "message from bobs past", timeslicer, 3.5 );
```
in this case the `recieveEvent` function of `alice` is called by the timeslicer `3.5` seconds later.  




## PeoteEvent API
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




## Macro helpers

To avoid extending `PeoteEvent<EventParam>` you can also use a build-macro to automatic generate 
the expected event-methods to make your own class-types event-ready.  
```
@:build( peote.event.PeoteEventMacro.build() )
class EventObject {...}
```
so into this case all `EventObject`-instances can listen and send events each other of same type.
The event-param-type then is the reference of an `EventObject` (e.g. into most case the "sender" itself).  
  
Another usecase would be to have a custom event-param-type and also some optional "postfix" for all
generated methods like this:  
```
@:build( peote.event.PeoteEventMacro.build( {param:Param, postfix:"Super"} ))
class EventObject {...}
```  
So instead of `listenEvent(...)` it will generated as `listenEventSuper(...)` and expect a callback
where the param-type is `Param`.  
  
You can also give a special type for senders and listeners, e.g. to use an Interface over multiple classes:
```
// a typedef is need because the macro functionarguments don't accept <TypeParameter>
typedef IPeoteEventParam = IPeoteEvent<Param>;

@:build( peote.event.PeoteEventMacro.build( {type:IPeoteEventParam, param:Param} ))
class A implements IPeoteEvent<Param> {...}

@:build( peote.event.PeoteEventMacro.build( {type:IPeoteEventParam, param:Param} ))
class B implements IPeoteEvent<Param> {...}
```  
  
  
More spicy things an be done by generating multiple Event-Types where each of them can recieve/send
to defined other ones with a unique "postfix" for all type-listen/send-specific types.
For this you have to use `.buildMulti()` with arguments like:  
```
@:build( peote.event.PeoteEventMacro.buildMulti(
	{listen:A, param:A}, // generates "listenEvent()" and so on (can listen to A)
	{listen:B, param:ParamB, postfix:"FromB"}, // generates "listenEventFromB()" etc.
	{send:A, param:A} // generates "sendEvent" (can send only to A)
))
class A {...}

@:build(peote.event.PeoteEventMacro.buildMulti(
   {listen:B, param:ParamB}, // generates "listenEvent()" (can listen to B)
   {send:B, param:ParamB},   // generates "sendEvent()"  (can send to B)
   {send:A, param:ParamB, postfix:"ToA"} // generates "sendEventToA()" (can send also to A)
))
class B {...}
```
  
  
Best to figure out how it works for more complex event-type-systems is to take a look at the [samples here](https://github.com/maitag/peote-event/tree/master/samples/src).  




## Todo

- more timeslicer methods
- more samples, unit and performance tests
- optimization
