package de.peote.events;

/**
 * ...
 * @author Sylvio Sell
 */

typedef ObservedBy<PARAM> = PeoteEventDLL<PARAM>;
typedef Observe<PARAM> = PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>;

class PeoteTimeEvent<PARAM>
{
	public var observed_by:ObservedBy<PARAM>;
	//public var observe:Observe<PARAM>;
	public var observe:PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>;
	
	public var timeslicer:PeoteTimeslicer<PARAM>;
	
	public function new(timeslicer:PeoteTimeslicer<PARAM>)
	{
		this.timeslicer = timeslicer;
		observed_by = new ObservedBy<PARAM>();
		observe     = new Observe<PARAM>();
	}
	
	public function sendTimeEvent(event_nr:Int, send_params:PARAM = null, delay:Float=0.0) {
		
		timeslicer.push(delay, observed_by, event_nr, send_params);
	}
	
	public function sendEvent(event_nr:Int, send_params:PARAM = null) {
		observed_by.send(event_nr, send_params);
	}
	
	public function listenEvent(obj:PeoteTimeEvent<PARAM>, event_nr:Int , callback:Int->PARAM->Void = null) {
		obj.observed_by.listen(observe, event_nr, callback);
	}
	
	public function unlistenEvent(obj:PeoteTimeEvent<PARAM>, event_nr:Int) {
		obj.observed_by.unlisten(observe, event_nr);
	}
	
	public function unlistenObj(obj:PeoteTimeEvent<PARAM>) {
		obj.observed_by.unlistenObj(observe);
	}
	
	public function unlistenAll() {
		observed_by.unlistenAll(observe); // mit observed_by wird nix gemacht, koennte auch statisch sein!!!
	}

	public function removeListener(obj:PeoteTimeEvent<PARAM>) {
		observed_by.unlistenObj(obj.observe);
	}

	public function removeAllListener() {
		observed_by.removeAllListener();
	}


}
