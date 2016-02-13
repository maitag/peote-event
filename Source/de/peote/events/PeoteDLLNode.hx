package de.peote.events;

/**
 * ...
 * @author Sylvio Sell
 */


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

}