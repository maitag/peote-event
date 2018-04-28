package;

import haxe.Timer;
import lime.app.Application;

import de.peote.events.PeoteEvent;

class TestEvents extends Application {
	
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
		
		c.sendEvent(1);
		
		c.sendEvent(2);
		
		//a.unlistenObj(b);
		//a.unlistenAll();
		
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
		
		a.unlistenObj(b);
		
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
		
		
		clear(); trace("------------------ TEST 5 -------------------");
		var update_time = Timer.stamp();
		
		a.notrace = true;
		b.notrace = true;
		c.notrace = true;
		
		for (i in 0...10000)
		{
			for (j in 0...10)
			{
				a.listenEvent( c, j );
				b.listenEvent( c, j );
			}
			
			for (j in 0...10)
			{
				c.sendEvent( j );
			}
			
			for (j in 0...10)
			{
				a.unlistenEvent( c, j );
				b.unlistenEvent( c, j );
			}
		}
		trace("time used: " + Math.round((Timer.stamp() - update_time)*1000)/1000);
	
		
		
		clear(); trace("------------------ TEST 6 -------------------");
		update_time = Timer.stamp();
		
		for (j in 0...10)
		{
			a.listenEvent( c, j );
			b.listenEvent( c, j );
		}
		for (i in 0...10000)
		{
			
			for (j in 0...10)
			{
				c.sendEvent( j );
			}
			
		}
		for (j in 0...10)
		{
			a.unlistenEvent( c, j );
			b.unlistenEvent( c, j );
		}
		trace("time used: " + Math.round((Timer.stamp() - update_time)*1000)/1000);
		
	}
	
	public function clear():Void 
	{
		trace("\n\n");
		a.clear(); b.clear(); c.clear();
	}
	
}

// ---------------------------------------------------------------------------

class WorldObject extends PeoteEvent<Param>
{
	public var name:String;
	public var notrace:Bool = false;
	
	public function new(name:String)
	{
		this.name = name;
		super();
	}

	public function recieveEvent(event_nr:Int, params:Param ):Void 
	{
		if (!notrace) trace('.... $name recieves event $event_nr' + ((params!=null) ? ' -> "${params.message}"' : ''));
	}
	
	public function clear():Void 
	{
		super.unlistenAll();
		super.removeAllListener();
	}
	// --------------------------------------------------
	// -------------- DEBUG -----------------------------
	

	override public function sendEvent(event_nr:Int, param:Param = null) {
		if (!notrace) trace(name + " send event " + event_nr + " to all listeners");
		super.sendEvent(event_nr, param);
	}
	
	override public function listenEvent(obj:PeoteEvent<Param>, event_nr:Int, callback:Int->Param->Void = null) {
		if (!notrace) trace(name + " listen to event " + event_nr + " of object " + cast(obj, WorldObject).name);
		if (callback == null) {
			callback = this.recieveEvent;
		}
		super.listenEvent( obj, event_nr, callback );
	}
	
	override public function unlistenEvent(obj:PeoteEvent<Param>, event_nr:Int) {
		if (!notrace) trace(name + " unlisten to event " + event_nr + " of object "+cast(obj,WorldObject).name);
		super.unlistenEvent( obj, event_nr );
	}
	
	override public function unlistenObj(obj:PeoteEvent<Param>) {
		if (!notrace) trace(name + " unlisten all events of object "+cast(obj,WorldObject).name);
		super.unlistenObj(obj);
	}
	
	override public function unlistenAll() {
		if (!notrace) trace(name + " unlisten all events of all objects");
		super.unlistenAll();
	}

	override public function removeListener(obj:PeoteEvent<Param>) {
		if (!notrace) trace(name + " removes all events that object="+cast(obj,WorldObject).name+" is listening to it");
		super.removeListener(obj);
	}

	override public function removeAllListener() {
		if (!notrace) trace(name + " removes all events from all object listening to it");
		super.removeAllListener();
	}

}
/*
typedef Param =
{
	?msg:String,
	//?more:Int
}*/
class Param 
{
	public var message:String;

	public function new(message:String) {
		this.message = message;
	}
}
