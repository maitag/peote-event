package;

/**
 * by Sylvio Sell - rostock 2022
 */

import lime.app.Application;

import peote.event.*;

class TestMacroGenMulti extends Application {
		
	public function new () {
		
		super ();
		
		var a1 = new WorldObjectA('a1');
		var a2 = new WorldObjectA('a2');
		
		var b1 = new WorldObjectB('b1');
		var b2 = new WorldObjectB('b2');
		
		a1.listenEventFromB( b1, MESSAGE, function(event:Int, param:ParamB) {
			trace('.... a1 recieves event $event' + ((param!=null) ? ' -> "${param.msg}"' : ''));
			a1.sendEvent(MESSAGE);
		});
		
		a2.listenEvent( a1, MESSAGE, function(event:Int, param:WorldObjectA) {
			trace('.... a2 recieves event $event' + ((param!=null) ? ' from "${param.name}"' : ''));
		});
		
		//b1.listenEvent( a1, MESSAGE, b1.recieveEvent.bind(a1, _) );
		//b1.listenEvent( a1, BEEP, b1.recieveEvent.bind(a1, _) );
		//b1.listenEvent( a2, BEEP, b1.recieveEvent.bind(a2, _) );
		
		b1.sendEventToA(MESSAGE, {msg:"hello"} );
		
		a1.sendEvent(BEEP);
		//a2.sendEvent(BEEP);
		
	}
}

// ---------------------------------------------------------------------------

// event-enums

enum abstract Event(Int) from Int to Int {
  var MESSAGE;
  var BEEP;
  var ENTER;
  var LEAVE;
}

// event-parameters

@:structInit
class ParamB
{
	public var msg:String;

	public function new(msg:String) {
		this.msg = msg;
	}
}

// ---------------------------------------------------------------------------

// building multiple listener for both WorldObject types
// without param it using same for param as the listen-object itself

@:build( peote.event.PeoteEventMacro.build(
	{listen:WorldObjectA, param:WorldObjectA},            // listenEvent
	{listen:WorldObjectB, param:ParamB, postfix:"FromB"}, // listenEventFromB
	{send:WorldObjectA, param:WorldObjectA}               // sendEvent (only to A)
))                                                   
class WorldObjectA
{
	public var name:String;		
	public function new(name:String) this.name = name;
}

// building multiple senders for both WorldObject types

@:build(peote.event.PeoteEventMacro.build(
   {listen:WorldObjectB, param:ParamB}, // listenEvent (only to B)
   {send:WorldObjectB, param:ParamB},   // sendEvent 
   {send:WorldObjectA, param:ParamB, postfix:"ToA"}  // sendEventToA
))
class WorldObjectB
{
	public var name:String;
	public function new(name:String) this.name = name;
	
/*	public function recieveEvent(fromWorldObjectA:WorldObjectA, event:Event, param:ParamB ):Void 
	{
		var eventname = switch(event) {
			case MESSAGE: "MESSAGE";
			case BEEP: "BEEP";
			case ENTER: "ENTER";
			case LEAVE: "LEAVE";
		}
		trace('.... $name recieves event $eventname from ${fromWorldObjectA.name}' + ((param!=null) ? ' -> "${param.msg}"' : ''));
	}
*/	
}
