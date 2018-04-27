package de.peote.events;

/**
 * ...
 * @author Sylvio Sell
 */

@:generic
class PeoteEventNode<PARAM>
{
	public var listen:PeoteDLLNode<PeoteDLLNode<PeoteEventNode<PARAM>>>;
	public var callback:Int->PARAM->Void;
	public var event_nr:Int;
	
	
	public inline function new(listen:PeoteDLLNode<PeoteDLLNode<PeoteEventNode<PARAM>>>, callback:Int->PARAM->Void, event_nr:Int):Void
	{
		this.listen = listen;
		this.callback = callback;
		this.event_nr = event_nr;
	}

}
