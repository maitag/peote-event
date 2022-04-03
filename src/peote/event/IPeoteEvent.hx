package peote.event;

@:generic
interface IPeoteEvent<PARAM> {
	private var observed_by:PeoteEventDLL<PARAM>;
	private var observe:PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>;	
	public function sendEvent(event:Int, params:PARAM = null):Void;
	public function sendTimeEvent(event:Int, params:PARAM = null, timeslicer:PeoteTimeslicer<PARAM>, delay:Float=0.0):Void;
	public function listenEvent(sender:IPeoteEvent<PARAM>, event:Int, callback:Int->PARAM->Void = null, checkEventExists:Bool = true):Void;
	public function unlistenEvent(sender:IPeoteEvent<PARAM>, event:Int):Void;
	public function unlistenFrom(sender:IPeoteEvent<PARAM>):Void;
	public function unlistenAll():Void;
	public function removeListener(listener:IPeoteEvent<PARAM>):Void;
	public function removeAllListener():Void;
}
