package de.peote.events;

/**
 * ...
 * @author Sylvio Sell
 */

typedef ObservedBy<PARAM> = PeoteEventDLL<PARAM>;
typedef Observe<PARAM> = PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>;


class PeoteEvent<PARAM>
{
	public var observed_by:ObservedBy<PARAM>;
	public var observe:Observe<PARAM>;
	
	public function new()
	{
		observed_by = new ObservedBy<PARAM>();
		observe     = new Observe<PARAM>();
	}
	
	public function sendEvent(event_nr:Int, params:PARAM = null) {
		observed_by.send(event_nr, params);
	}
	
	public function listenEvent(obj:PeoteEvent<PARAM>, event_nr:Int , callback:Int->PARAM->Void = null) {
		obj.observed_by.listen(observe, event_nr, callback);
	}
	
	public function unlistenEvent(obj:PeoteEvent<PARAM>, event_nr:Int) {
		obj.observed_by.unlisten(observe, event_nr);
	}
	
	public function unlistenObj(obj:PeoteEvent<PARAM>) {
		obj.observed_by.unlistenObj(observe);
	}
	
	public function unlistenAll() {
		observed_by.unlistenAll(observe);
	}

	public function removeListener(obj:PeoteEvent<PARAM>) {
		observed_by.unlistenObj(obj.observe);
	}

	public function removeAllListener() {
		observed_by.removeAllListener();
	}

	
	

}
