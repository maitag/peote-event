package;

/**
 * by Sylvio Sell - rostock 2015
 */

import haxe.Timer;
import lime.app.Application;

import peote.event.*;

class TestMacroGen extends Application {
		
	
	public function new () {
		
		super ();
		
		var a1 = new WorldObjectA('a1');
		var a2 = new WorldObjectA('a2');
		
		var b1 = new WorldObjectB('b1');
		
		a1.listenEvent( b1, 1, function(event:Int, param:Param) {
			trace(event, param);
			a1.sendEvent(2);
		});
		a2.listenEvent( a1, 2, function(event:Int, param:Param) {
			trace(event, param);
		});
		
		b1.sendEvent(1, {msg:"hello"} );
	}
}

// ---------------------------------------------------------------------------
@:structInit
class Param
{
	public var msg:String;

	public function new(msg:String) {
		this.msg = msg;
	}
}

// ---------------------------------------------------------------------------
@:build(peote.event.PeoteEventMacro.build(Param)) // TODO: more params to auto add Interfaces for Listener and Sender 
class WorldObjectA implements IPeoteEvent<Param>
{
	public var name:String;	
	
	public function new(name:String)
	{
		this.name = name;
	}
	
	public function recieveEvent(event:Int, params:Param ):Void 
	{
		trace('.... $name recieves event $event' + ((params!=null) ? ' -> "${params.msg}"' : ''));
	}
	

}


@:build(peote.event.PeoteEventMacro.build(Param))
class WorldObjectB implements IPeoteEvent<Param>
{
	public var name:String;
	
	public function new(name:String)
	{
		this.name = name;
	}
	
	public function unlistenAll():Void {};

}
