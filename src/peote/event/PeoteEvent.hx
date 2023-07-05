package peote.event;

/**
 * by Sylvio Sell - rostock 2015
 */

@:generic
class PeoteEvent<PARAM>
{
	var observed_by:PeoteEventDLL<PARAM>;
	var observe:PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>;
	
	public function new()
	{
		observed_by = new PeoteEventDLL<PARAM>();
		observe     = new PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>();
	}
	
	/**
		sending an event to all listeners.
		@param  event  a number that represents an event
		@param  params object of user defined type that holds the params for the recieve-callback
	**/
	public function sendEvent(event:Int, params:PARAM = null):Void {
		observed_by.send(event, params);
	}
	
	/**
		sending an event to all listeners after a delay-time.
		@param  event  a number that represents an event
		@param  params object of user defined type that holds the params for the recieve-callback
		@param  timeslicer reference to the time-scheduler
		@param  delay  time to wait before sending the event to all listeners 
	**/
	public function sendTimeEvent(event:Int, params:PARAM = null, timeslicer:PeoteTimeslicer<PARAM>, delay:Float=0.0):Void {	
		timeslicer.push(delay, observed_by, event, params);
	}
	
	/**
		listen to an object for an event.
		@param  sender the object that will send the event
		@param  event  a number that represents an event
		@param  callback a function that will recieve this event inclusive parameters
		@param  checkEventExists if true, old listenings to that event will deleted before setting a new one
	**/
	public function listenEvent(sender:PeoteEvent<PARAM>, event:Int, callback:Int->PARAM->Void = null, checkEventExists:Bool = true):Void {
		sender.observed_by.listen(observe, event, callback, checkEventExists);
	}
	
	/**
		stops listening of a specific event from the sender-object.
		@param  sender the object that will send the event
		@param  event  a number that represents an event
	**/
	public function unlistenEvent(sender:PeoteEvent<PARAM>, event:Int):Void {
		sender.observed_by.unlisten(observe, event);
	}
	
	/**
		stops listening of all events from the sender-object.
		@param  sender the object that will send the event
	**/
	public function unlistenFrom(sender:PeoteEvent<PARAM>):Void {
		sender.observed_by.unlistenObj(observe);
	}
	
	/**
		stops listening to all sender-objects.
	**/
	public function unlistenAll():Void {
		// observed_by.unlistenAll(observe);
		
		// without need of observed_by (e.g. into macro and for listeners only):
		var obsnode = observe.head;
		while (obsnode != null)
		{	
			obsnode.node.dll.unlink(obsnode.node);
			obsnode = obsnode.next;
			//obsnode = obsnode.nextClear(); // GC-optimization
		}
		observe.head = null;
		
		// ToRememberMe: if this would be inserted directly into PeoteDLL.hx to simple call
		// "observe.unlistenAll();" from here ...
		// it could send your haxe-compiler into a generic-endless-loop *lol (^_^)
		// (TODO: figure this out into a simple try.haxe sample for the devels! ;)
	}

	/**
		removes a specific listener-object.
		@param  listener  a reciever-object that is listen to this object
	**/
	public function removeListener(listener:PeoteEvent<PARAM>):Void {
		observed_by.unlistenObj(listener.observe);
	}

	/**
		removes all listener-objects.
	**/
	public function removeAllListener():Void {
		observed_by.removeAllListener();
	}

	
	

}
