package peote.event;

/**
 * by Sylvio Sell - rostock 2015
 */

import haxe.ds.Vector;
import haxe.Timer;

@:generic @:keep
class PeoteTimeslicer<PARAM>
{
	var size:Int;
	var stepsPerSecond:Int;
	var maxSeconds:Float;
	var speedFactor:Float; // TODO: make public an getter/setter to change while running
	var slot:Int = 0;
	var timer:Timer;
	
	var commandTable:Vector<Array<NextEvent<PARAM>>>;
	
	public function new(maxSeconds:Int = 60, stepsPerSecond:Int = 10, speedFactor:Float = 1.0) 
	{
		this.size = maxSeconds * stepsPerSecond + 1;
		this.stepsPerSecond = stepsPerSecond;
		this.maxSeconds = maxSeconds;

		commandTable = new Vector<Array<NextEvent<PARAM>>>(size);
		for (i in 0...size)
		{	
			commandTable[i] = new Array<NextEvent<PARAM>>();
		}
		
		timer = new Timer(Math.floor(speedFactor * 1000/stepsPerSecond));
		
	}
	
	public inline function start():Void
	{
		timer.run = allSteps;
	}
	
	public inline function stop():Void
	{
		timer.stop();
	}

	public inline function push(delay:Float, observed_by:PeoteEventDLL<PARAM>, event_nr:Int, params:PARAM ):Void 
	{	
		//trace('push command '+ ( (slot+Math.round(Math.min(size-1, delay * stepsPerSecond)))%size ));
		if (delay > maxSeconds) throw('Error, PeoteTimeslicer can only store events with a maximum delay of $maxSeconds seconds');
		commandTable[(slot+Math.round(Math.min(size-1, delay * stepsPerSecond)))%size].push(new NextEvent<PARAM>(observed_by, event_nr, params));
	}
	
	public inline function allSteps():Void 
	{	
		while (commandTable[slot].length > 0) step();
		
		var last_slot:Int = slot;
		slot = (slot + 1) % size;
		
		// to take care that no one get lost in last timestep ;)
		while (commandTable[last_slot].length > 0) step();
	}	
	
	var nextEvent:NextEvent<PARAM>;
	public inline function step():Void
	{
			nextEvent = commandTable[slot].shift();
			nextEvent.observed_by.send(nextEvent.event_nr, nextEvent.params);
	}

}

@:generic
class NextEvent<PARAM>
{
	public var observed_by:PeoteEventDLL<PARAM>;
	public var event_nr:Int;
	public var params:PARAM;
	
	public function new(observed_by:PeoteEventDLL<PARAM>, event_nr:Int, params:PARAM)
	{
		this.observed_by = observed_by;
		this.event_nr = event_nr;
		this.params = params;
	}
}

