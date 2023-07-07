package test.actor;

//import test.cell.Cell;
//import test.params.Param;

@:build( peote.event.PeoteEventMacro.buildMulti(
	{listen:Actor, param:Actor},            // listenEvent
	{send:Actor, param:Actor},              // sendEvent 
	{listen:test.cell.Cell, param:test.params.Param, postfix:"FromCell"} // listenEventFromCell
))                                                   
class Actor
{
	public var name:String;		
	public function new(name:String) this.name = name;
}
