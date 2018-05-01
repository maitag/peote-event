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
	
	public function sendEvent(event:Int, params:PARAM = null) {
		observed_by.send(event, params);
	}
	
	public function sendTimeEvent(event:Int, params:PARAM = null, timeslicer:PeoteTimeslicer<PARAM>, delay:Float=0.0) {	
		timeslicer.push(delay, observed_by, event, params);
	}
	
	public function listenEvent(sender:PeoteEvent<PARAM>, event:Int, callback:Int->PARAM->Void = null, checkEventExists:Bool = true) {
		sender.observed_by.listen(observe, event, callback, checkEventExists);
	}
	
	public function unlistenEvent(sender:PeoteEvent<PARAM>, event:Int) {
		sender.observed_by.unlisten(observe, event);
	}
	
	public function unlistenFrom(sender:PeoteEvent<PARAM>) {
		sender.observed_by.unlistenObj(observe);
	}
	
	public function unlistenAll() {
		observed_by.unlistenAll(observe);
	}

	public function removeListener(listener:PeoteEvent<PARAM>) {
		observed_by.unlistenObj(listener.observe);
	}

	public function removeAllListener() {
		observed_by.removeAllListener();
	}

	
	

}
