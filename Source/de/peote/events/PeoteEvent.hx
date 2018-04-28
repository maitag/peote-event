package de.peote.events;

/**
 * ...
 * @author Sylvio Sell
 */

typedef ObservedBy<PARAM> = PeoteEventDLL<PARAM>;
typedef Observe<PARAM> = PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>;


class PeoteEvent<PARAM>
{
	var observed_by:ObservedBy<PARAM>;
	var observe:Observe<PARAM>;
	
	public function new()
	{
		observed_by = new ObservedBy<PARAM>();
		observe     = new Observe<PARAM>();
	}
	
	public function sendEvent(event:Int, params:PARAM = null) {
		observed_by.send(event, params);
	}
	
	public function listenEvent(sender:PeoteEvent<PARAM>, event:Int, callback:Int->PARAM->Void) {
		sender.observed_by.listen(observe, event, callback);
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
