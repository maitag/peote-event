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
		
		var timeslicer:PeoteTimeslicer<Param> = new PeoteTimeslicer<Param>(60,10);
		
		timeslicer.start();
		
		a = new WorldObject('a', timeslicer);
		b = new WorldObject('b', timeslicer);
		c = new WorldObject('c', timeslicer);
		
		clear(); trace("------------------ TEST 1 -------------------");
		
		a.listen( c, 1 );
		a.listen( c, 3 );
		b.listen( c, 2 );
		b.listen( c, 3 , function(e:Int, p:Param) { b.send(1, new Param("roger")); } );
		c.listen( b, 1);

		c.send(1, new Param("direct call") );
		c.sendDelayed(2, new Param("imediadly call via timeslicer") );
		
		//a.unlistenObj(b);
		//a.unlistenAll();
		
		//a.unlisten( c, 1 );
		c.sendDelayed(1, new Param("someone on channel 1 ?"), 0.1 );
		
		a.unlisten( c, 2 ); // TODO: did not work on neko!
		c.sendDelayed(3, new Param("do u hear me on channel 3 ?") , 3.5 );

		// throws an error because 61 seconds is greater then maxSeconds in timeslicer
		// c.sendDelayed(3, new Param("do u hear me on channel 3 ?") , 61 );
		
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
	

	public function send(event:Int, param:Param = null) {
		if (!notrace) trace('$name sends event $event to all listeners');
		super.sendEvent(event, param);
	}
	
	public function sendDelayed(event:Int, param:Param = null, delay:Float=0.0) {
		if (!notrace) trace('$name sends event $event to all listeners with a delay of $delay seconds');
		super.sendTimeEvent(event, param, delay);
	}
	
	public function listen(sender:PeoteTimeEvent<Param>, event:Int, callback:Int->Param->Void = null) {
		if (!notrace) trace('$name is listen to event $event of object ${cast(sender, WorldObject).name}');
		if (callback == null) {
			callback = this.recieveEvent;
		}
		super.listenEvent( sender, event, callback );
	}
	
	public function unlisten(sender:PeoteTimeEvent<Param>, event:Int) {
		if (!notrace) trace('$name stops listening to event $event of object ${cast(sender,WorldObject).name}');
		super.unlistenEvent( sender, event );
	}
	
	override public function unlistenFrom(sender:PeoteTimeEvent<Param>) {
		if (!notrace) trace('$name stops listening to all events of object ${cast(sender,WorldObject).name}');
		super.unlistenFrom(sender);
	}
	
	override public function unlistenAll() {
		if (!notrace) trace('$name stops listening to all events of all objects');
		super.unlistenAll();
	}

	override public function removeListener(listener:PeoteTimeEvent<Param>) {
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

