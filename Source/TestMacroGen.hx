package;

/**
 * by Sylvio Sell - rostock 2022
 */

import lime.app.Application;

import peote.event.*;

class TestMacroGen extends Application {
		
	public function new () {
		
		super ();
		
		var a1 = new WorldObjectA('a1');
		var a2 = new WorldObjectA('a2');
		
		var b1 = new WorldObjectB('b1');
		
		a1.listenEvent( b1, MESSAGE, function(event:Int, param:Param) {
			trace('.... a1 recieves event $event' + ((param!=null) ? ' -> "${param.msg}"' : ''));
			a1.sendEvent(MESSAGE);
		});
		
		a2.listenEvent( a1, MESSAGE, function(event:Int, param:Param) {
			trace('.... a2 recieves event $event' + ((param!=null) ? ' -> "${param.msg}"' : ''));
		});
		
		b1.listenEvent( a1, MESSAGE, b1.recieveEvent.bind(a1, _) );
		b1.listenEvent( a1, BEEP, b1.recieveEvent.bind(a1, _) );
		b1.listenEvent( a2, BEEP, b1.recieveEvent.bind(a2, _) );
		
		b1.sendEvent(MESSAGE, {msg:"hello"} );
		
		a1.sendEvent(BEEP);
		a2.sendEvent(BEEP);
		
	}
}

// ---------------------------------------------------------------------------

@:enum abstract Event(Int) from Int to Int {
  var MESSAGE;
  var BEEP;
  var ENTER;
  var LEAVE;
}

@:structInit
class Param
{
	public var msg:String;

	public function new(msg:String) {
		this.msg = msg;
	}
}

// ---------------------------------------------------------------------------

@:build(peote.event.PeoteEventMacro.build(Param)) // TODO: customizing to let ".listenEvent(sender:IPeoteEvent<Param>, ...)" also use the class itself instead of using the Interface
class WorldObjectA implements IPeoteEvent<Param>
{
	public var name:String;		
	public function new(name:String) this.name = name;
}


@:build(peote.event.PeoteEventMacro.build(Param))
class WorldObjectB implements IPeoteEvent<Param>
{
	public var name:String;
	public function new(name:String) this.name = name;
	
	public function recieveEvent(fromWorldObjectA:WorldObjectA, event:Event, param:Param ):Void 
	{
		var eventname = switch(event) {
			case MESSAGE: "MESSAGE";
			case BEEP: "BEEP";
			case ENTER: "ENTER";
			case LEAVE: "LEAVE";
		}
		trace('.... $name recieves event $eventname from ${fromWorldObjectA.name}' + ((param!=null) ? ' -> "${param.msg}"' : ''));
	}
}
