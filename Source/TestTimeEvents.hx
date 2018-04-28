package;

import de.peote.events.PeoteTimeslicer;

import lime.app.Application;

import de.peote.events.PeoteTimeEvent;

class TestTimeEvents extends Application {
	
	var a:WorldObject;
	var b:WorldObject;
	var c:WorldObject;
	
	public function new () {
		
		super ();
		
		var timeslicer:PeoteTimeslicer<Param> = new PeoteTimeslicer<Param>(3,10);
		
		timeslicer.start();
		
		a = new WorldObject('a', timeslicer);
		b = new WorldObject('b', timeslicer);
		c = new WorldObject('c', timeslicer);
		
		clear(); trace("------------------ TEST 1 -------------------");
		
		a.listenEvent( c, 1 );
		a.listenEvent( c, 3 );
		b.listenEvent( c, 2 );
		b.listenEvent( c, 3 , function(e:Int, p:Param) { b.sendEvent(1, new Param("roger")); } );
		c.listenEvent( b, 1);

		c.sendTimeEvent(1, new Param("imediadly") );
		c.sendTimeEvent(2, new Param("imediadly") );
		
		//a.unlistenObj(b);
		//a.unlistenAll();
		
		//a.unlistenEvent( c, 1 );
		c.sendTimeEvent(1, new Param("someone on channel 1 ?"), 0.1 );
		
		a.unlistenEvent( c, 2 ); // TODO: did not work on neko!
		c.sendTimeEvent(3, new Param("do u hear me on channel 3 ?") , 3.5 );
		
		/*
		clear(); trace("------------------ TEST 6 -------------------");
		update_time = Timer.stamp();
		trace("time used: " + Math.round((Timer.stamp() - update_time)*1000)/1000);
		*/
	}
	
	public function clear():Void 
	{
		trace("\n\n");
		a.clear(); b.clear(); c.clear();
	}
	
}

// ---------------------------------------------------------------------------

class WorldObject extends PeoteTimeEvent<Param>
{
	public var name:String;
	public var notrace:Bool = false;
	
	public function new(name:String, timeslicer:PeoteTimeslicer<Param>)
	{
		this.name = name;
		super(timeslicer);
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
	
	override public function listenEvent(obj:PeoteTimeEvent<Param>, event_nr:Int, callback:Int->Param->Void = null) {
		if (!notrace) trace(name + " listen to event " + event_nr + " of object " + cast(obj, WorldObject).name);
		if (callback == null) {
			callback = this.recieveEvent;
		}
		super.listenEvent( obj, event_nr, callback );
	}
	
	override public function unlistenEvent(obj:PeoteTimeEvent<Param>, event_nr:Int) {
		if (!notrace) trace(name + " unlisten to event " + event_nr + " of object "+cast(obj,WorldObject).name);
		super.unlistenEvent( obj, event_nr );
	}
	
	override public function unlistenObj(obj:PeoteTimeEvent<Param>) {
		if (!notrace) trace(name + " unlisten all events of object "+cast(obj,WorldObject).name);
		super.unlistenObj(obj);
	}
	
	override public function unlistenAll() {
		if (!notrace) trace(name + " unlisten all events of all objects");
		super.unlistenAll();
	}

	override public function removeListener(obj:PeoteTimeEvent<Param>) {
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

