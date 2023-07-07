package;

import haxe.Timer;
import lime.app.Application;

import peote.event.PeoteEvent;
import peote.event.PeoteTimeslicer;

class TestMacroGenSingle extends Application {
	
	var a:WorldObject;
	var b:WorldObject;
	var c:WorldObject;
	
	public function new () {
		
		super ();
		
		a = new WorldObject('a');
		b = new WorldObject('b');
		c = new WorldObject('c');
		
		clear(); trace("------------------ TEST 1 -------------------");
		
		a.listenEvent( c, 1 );
		a.listenEvent( c, 2 );
		b.listenEvent( c, 2 );
		
		//a.unlistenAll();
		c.sendEvent(1);
		
		c.sendEvent(2);
		
		//a.unlistenFrom(b);
		a.unlistenAll();
		
		a.unlistenEvent( c, 1 );
		c.sendEvent(1, new Param('someone on channel 1 ?') );
		
		a.unlistenEvent( c, 2 );
		c.sendEvent(2, new Param('do u hear me on channel 2 ?') );
		
		
		
		clear(); trace("------------------ TEST 2 -------------------");
		a.listenEvent(b, 1);
		a.listenEvent(b, 2);
		a.listenEvent(c, 1);
		b.listenEvent(c, 1);
		b.listenEvent(a, 1);
		c.listenEvent(a, 1);
		c.listenEvent(b, 1);
		c.listenEvent(b, 2);
		
		a.unlistenFrom(b);
		
		a.sendEvent(1);
		b.sendEvent(1);
		b.sendEvent(2);
		c.sendEvent(1);
		
		
		
		clear(); trace("------------------ TEST 3 -------------------");
		a.listenEvent(b, 1);
		a.listenEvent(b, 2);
		c.listenEvent(b, 1);
		c.listenEvent(b, 2);

		b.removeListener(a);
		
		b.sendEvent(1);
		b.sendEvent(2);
		
		
		
		clear(); trace("------------------ TEST 4 -------------------");
		a.listenEvent(b, 1);
		a.listenEvent(b, 1);
		b.sendEvent(1, new Param('stupid if events arrives twice' ));
		
		a.listenEvent(b, 1, false);
		b.sendEvent(1, new Param('oh noo, now it arrives twice' ));
		
		
		
		clear(); trace("------- TEST TIME-EVENTS AND TIMESLICER -------------------");

		var timeslicer:PeoteTimeslicer<Param> = new PeoteTimeslicer<Param>(60, 10); // maxSeconds, stepsPerSecondz
		timeslicer.start();
		
		a = new WorldObject('a');
		b = new WorldObject('b');
		c = new WorldObject('c');
			
		a.listenEvent( c, 1 );
		a.listenEvent( c, 3 );
		b.listenEvent( c, 2 );
		b.listenEvent( c, 3 , function(event:Int, params:Param) {
			trace('.... ${b.name} recieves event $event' + ((params!=null) ? ' -> "${params.message}"' : ''));
			b.sendEvent(1, new Param("roger")); 
		});
		c.listenEvent( b, 1);

		c.sendEvent(1, new Param("direct call") );
		c.sendTimeEvent( 2, new Param("imediadly call"), timeslicer );
				
		//a.unlistenEvent( c, 1 );
		c.sendTimeEvent( 1, new Param("someone on channel 1 ?"), timeslicer, 0.1 ); // 0.1 seconds
		
		a.unlistenEvent( c, 2 );
		c.sendTimeEvent( 3, new Param("do u hear me on channel 3 ?"), timeslicer , 3.5 ); // 3.5 seconds

		// throws an error because 61 seconds is greater then maxSeconds in timeslicer
		// c.sendDelayed(3, new Param("do u hear me on channel 3 ?"), timeslicer, 61 );
		
		
		
		clear(); trace("------------------ SPEED-TEST -------------------");
		trace('time for 3 000 000 calls ...');
		
		a.notrace = true;
		b.notrace = true;
		c.notrace = true;
		
		var update_time:Float;
		var listen_time:Float = 0.0;
		var send_time:Float = 0.0;
		var unlisten_time:Float = 0.0;
		for (i in 0...100000)
		{
			update_time = Timer.stamp();
			for (j in 0...10)
			{
				a.listenEvent( c, j );
				b.listenEvent( c, j );
				//a.listenEvent( c, j, false );
				//b.listenEvent( c, j, false );
			}
			listen_time += (Timer.stamp() - update_time);
			
			update_time = Timer.stamp();
			for (j in 0...10)
			{
				c.sendEvent( j );
			}
			send_time += (Timer.stamp() - update_time);
			
			update_time = Timer.stamp();
			for (j in 0...10)
			{
				a.unlistenEvent( c, j );
				b.unlistenEvent( c, j );
			}
			unlisten_time += (Timer.stamp() - update_time);
		}
		listen_time = Math.round((listen_time) * 1000) / 1000;
		send_time = Math.round((send_time) * 1000) / 1000;
		unlisten_time = Math.round((unlisten_time) * 1000) / 1000;
		trace('"listenEvent"  : ${Math.round((listen_time) * 1000) / 1000} seconds');
		trace('"sendEvent"    : ${Math.round((send_time) * 1000) / 1000} seconds');
		trace('"unlistenEvent": ${Math.round((unlisten_time) * 1000) / 1000} seconds');	
		
	}
	
	public function clear():Void 
	{
		trace("\n\n");
		a.clear(); b.clear(); c.clear();
	}
	
}

// ---------------------------------------------------------------------------

// event-parameters

/*typedef Param =
{
	?msg:String,
	//?more:Int
}*/

//@:structInit
class Param 
{
	public var message:String;

	public function new(message:String) {
		this.message = message;
	}
}

// ---------------------------------------------------------------------------

// single class by extending PeoteEvent

@:build( peote.event.PeoteEventMacro.build( {param:Param, postfix:"Super"} ))
class WorldObject
{
	public var name:String;
	public var notrace:Bool = false;
	
	public function new(name:String)
	{
		this.name = name;
	}

	public function recieveEvent(event:Int, params:Param ):Void 
	{
		if (!notrace) trace('.... $name recieves event $event' + ((params!=null) ? ' -> "${params.message}"' : ''));
	}
	
	public function clear():Void 
	{
		unlistenAllSuper();
		removeAllListenerSuper();
	}
	// --------------------------------------------------
	// -------------- DEBUG -----------------------------
	

	public function sendEvent(event:Int, param:Param = null) {
		if (!notrace) trace('$name sends event $event to all listeners');
		sendEventSuper(event, param);
	}
	
	public function sendTimeEvent( event:Int, param:Param = null, timeslicer:PeoteTimeslicer<Param>, delay:Float=0.0) {
		if (!notrace) trace('$name sends event $event to all listeners with a delay of $delay seconds');
		sendTimeEventSuper(event, param, timeslicer, delay);
	}
	
	public function listenEvent(sender:WorldObject, event:Int, callback:Int->Param->Void = null, checkEventExists:Bool=true) {
		if (!notrace) trace('$name is listen to event $event of object ${cast(sender, WorldObject).name}'+((!checkEventExists)? ' (faster but not removes existing listener $event)':""));
		if (callback == null) {
			callback = this.recieveEvent;
		}
		listenEventSuper( sender, event, callback, checkEventExists ); // add false as last parameter to speed up
	}
	
	public function unlistenEvent(sender:WorldObject, event:Int) {
		if (!notrace) trace('$name stops listening to event $event of object ${cast(sender,WorldObject).name}');
		unlistenEventSuper( sender, event );
	}
	
	public function unlistenFrom(sender:WorldObject) {
		if (!notrace) trace('$name stops listening to all events of object ${cast(sender,WorldObject).name}');
		unlistenFromSuper(sender);
	}
	
	public function unlistenAll() {
		if (!notrace) trace('$name stops listening to all events of all objects');
		unlistenAllSuper();
	}

	public function removeListener(listener:WorldObject) {
		if (!notrace) trace('$name removes all events that object ${cast(listener,WorldObject).name} is listening to it');
		removeListenerSuper(listener);
	}

	public function removeAllListener() {
		if (!notrace) trace('$name removes all events from all object that is listening to it');
		removeAllListenerSuper();
	}

}
