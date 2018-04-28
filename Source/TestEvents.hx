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
		
		a.listen( c, 1 );
		a.listen( c, 2 );
		b.listen( c, 2 );
		
		c.send(1);
		
		c.send(2);
		
		//a.unlistenObj(b);
		//a.unlistenAll();
		
		a.unlisten( c, 1 );
		c.send(1, new Param('someone on channel 1 ?') );
		
		a.unlisten( c, 2 );
		c.send(2, new Param('do u hear me on channel 2 ?') );
		
		
		
		clear(); trace("------------------ TEST 2 -------------------");
		a.listen(b, 1);
		a.listen(b, 2);
		a.listen(c, 1);
		b.listen(c, 1);
		b.listen(a, 1);
		c.listen(a, 1);
		c.listen(b, 1);
		c.listen(b, 2);
		
		a.unlistenFrom(b);
		
		a.send(1);
		b.send(1);
		b.send(2);
		c.send(1);
		
		
		
		clear(); trace("------------------ TEST 3 -------------------");
		a.listen(b, 1);
		a.listen(b, 2);
		c.listen(b, 1);
		c.listen(b, 2);

		b.removeListener(a);
		
		b.send(1);
		b.send(2);
		
		
		
		clear(); trace("------------------ TEST 4 -------------------");
		a.listen(b, 1);
		a.listen(b, 1);
		b.send(1, new Param('stupid if events arrives twice' ));
		
		
		clear(); trace("------------------ TEST 5 -------------------");
		var update_time = Timer.stamp();
		
		a.notrace = true;
		b.notrace = true;
		c.notrace = true;
		
		for (i in 0...10000)
		{
			for (j in 0...10)
			{
				a.listen( c, j );
				b.listen( c, j );
			}
			
			for (j in 0...10)
			{
				c.send( j );
			}
			
			for (j in 0...10)
			{
				a.unlisten( c, j );
				b.unlisten( c, j );
			}
		}
		trace("time used: " + Math.round((Timer.stamp() - update_time)*1000)/1000);
	
		
		
		clear(); trace("------------------ TEST 6 -------------------");
		update_time = Timer.stamp();
		
		for (j in 0...10)
		{
			a.listen( c, j );
			b.listen( c, j );
		}
		for (i in 0...10000)
		{
			
			for (j in 0...10)
			{
				c.send( j );
			}
			
		}
		for (j in 0...10)
		{
			a.unlisten( c, j );
			b.unlisten( c, j );
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
	

	public function send(event:Int, param:Param = null) {
		if (!notrace) trace('$name sends event $event to all listeners');
		super.sendEvent(event, param);
	}
	
	public function listen(sender:PeoteEvent<Param>, event:Int, callback:Int->Param->Void = null) {
		if (!notrace) trace('$name is listen to event $event of object ${cast(sender, WorldObject).name}');
		if (callback == null) {
			callback = this.recieveEvent;
		}
		super.listenEvent( sender, event, callback );
	}
	
	public function unlisten(sender:PeoteEvent<Param>, event:Int) {
		if (!notrace) trace('$name stops listening to event $event of object ${cast(sender,WorldObject).name}');
		super.unlistenEvent( sender, event );
	}
	
	override public function unlistenFrom(sender:PeoteEvent<Param>) {
		if (!notrace) trace('$name stops listening to all events of object ${cast(sender,WorldObject).name}');
		super.unlistenFrom(sender);
	}
	
	override public function unlistenAll() {
		if (!notrace) trace('$name stops listening to all events of all objects');
		super.unlistenAll();
	}

	override public function removeListener(listener:PeoteEvent<Param>) {
		if (!notrace) trace('$name removes all events that object ${cast(listener,WorldObject).name} is listening to it');
		super.removeListener(listener);
	}

	override public function removeAllListener() {
		if (!notrace) trace('$name removes all events from all object that is listening to it');
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
