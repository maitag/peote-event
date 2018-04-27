package de.peote.events;

/**
 * ...
 * @author Sylvio Sell
 */
@:generic
class PeoteDLL<T>
{
	public var head:PeoteDLLNode<T>;
	var n:PeoteDLLNode<T>;
	
	public function new()
	{
		head = null;
	}
	
	inline public function append(newnode:T):PeoteDLLNode<T>
	{
		// TODO: optimize here with binary tree linked nodes and insert-sort,
		//       so sending events could faster find event-nr
		
		n = new PeoteDLLNode<T>(newnode, this);
		n.next = head;
		if (head != null) head.prev = n;
		head = n;
		return n;
	}
	

	inline public function unlink(node:PeoteDLLNode<T>):PeoteDLLNode<T>
	{
		
		if (node == head)
		{
			if (node.next != null)
			{
				head = node.next;
				node.next.prev = null;
			}
			else head = null;
		}
		else
		{
			if (node.next != null)
			{
				node.prev.next = node.next;
				node.next.prev = node.prev;
			}
			else node.prev.next = null; // last
		}
		return node.next;
		//return node.nextClear();  // GC-optimization ?
	}

}