package de.peote.events;

/**
 * ...
 * @author Sylvio Sell
 */

typedef ObservedBy<PARAM> = PeoteEventDLL<PARAM>;
typedef Observe<PARAM> = PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>;


class PeoteTimeEvent<PARAM>
{
	var observed_by:ObservedBy<PARAM>;
	var observe:Observe<PARAM>;
	
	var timeslicer:PeoteTimeslicer<PARAM>;
	
	public function new(timeslicer:PeoteTimeslicer<PARAM>)
	{
		this.timeslicer = timeslicer;
		observed_by = new ObservedBy<PARAM>();
		observe     = new Observe<PARAM>();
	}
	
	public function sendTimeEvent(event:Int, send_params:PARAM = null, delay:Float=0.0) {	
		timeslicer.push(delay, observed_by, event, send_params);
	}
	
	public function sendEvent(event:Int, params:PARAM = null) {
		observed_by.send(event, params);
	}
	
	public function listenEvent(sender:PeoteTimeEvent<PARAM>, event:Int, callback:Int->PARAM->Void) {
		sender.observed_by.listen(observe, event, callback);
	}
	
	public function unlistenEvent(sender:PeoteTimeEvent<PARAM>, event:Int) {
		sender.observed_by.unlisten(observe, event);
	}
	
	public function unlistenFrom(sender:PeoteTimeEvent<PARAM>) {
		sender.observed_by.unlistenObj(observe);
	}
	
	public function unlistenAll() {
		observed_by.unlistenAll(observe); // mit observed_by wird nix gemacht, koennte auch statisch sein!!!
	}

	public function removeListener(listener:PeoteTimeEvent<PARAM>) {
		observed_by.unlistenObj(listener.observe);
	}

	public function removeAllListener() {
		observed_by.removeAllListener();
	}


}
