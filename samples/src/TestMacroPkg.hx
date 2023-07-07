package;

import lime.app.Application;

import peote.event.*;

// test if event-classes and params is into separate packages
import test.params.Param;
import test.cell.Cell;
import test.actor.Actor;

class TestMacroPkg extends Application {
		
	public function new () {
		
		super ();
		
		var a1 = new Actor('a1');
		var c1 = new Cell('c1');
		var c2 = new Cell('c2');
		
		a1.listenEventFromCell(c2, 1, (e:Int, p:Param)->{trace("a1:revieve event from c1", e, p.msg); } );
		c1.listenEvent(c2, 1, (e:Int, p:Param)->{trace("c1:revieve event from c1", e, p.msg); } );
		
		c2.sendEventToActor(1, new Param("test"));
		c2.sendEvent(1, new Param("test"));
	}
}
