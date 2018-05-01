package de.peote.events;

/**
 * ...
 * @author Sylvio Sell
 */

@:generic
class PeoteDLLNode<T>
{
	public var node:T;
	public var next:PeoteDLLNode<T>;
	public var prev:PeoteDLLNode<T>;
	public var dll:PeoteDLL<T>;

	inline public function new(newnode:T, list:PeoteDLL<T>)
	{
		node = newnode;
		dll = list;
	}
	
	inline public function nextClear():PeoteDLLNode<T>  // GC-optimization ?
	{
		node = null;
		prev = null;
		dll = null;
		return next;
	}
	
}