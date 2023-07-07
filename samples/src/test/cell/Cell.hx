package test.cell;

import test.params.Param;
//import test.actor.Actor;

@:build(peote.event.PeoteEventMacro.buildMulti(
   {listen:Cell, param:Param}, // listenEvent 
   {send:Cell, param:Param},   // sendEvent 
   {send:test.actor.Actor, param:test.params.Param, postfix:"ToActor"}  // sendEventToActor
))
class Cell
{
	public var name:String;
	public function new(name:String) this.name = name;	
}
