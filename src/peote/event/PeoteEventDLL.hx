package peote.event;

/**
 * by Sylvio Sell - rostock 2015
 */

@:generic
class PeoteEventDLL<PARAM> extends PeoteDLL<PeoteEventNode<PARAM>>
{
	var node:PeoteDLLNode<PeoteEventNode<PARAM>>;
	var obsnode:PeoteDLLNode<PeoteDLLNode<PeoteEventNode<PARAM>>>;
	
	public inline function send(event_nr:Int, send_params:PARAM):Void
	{	
		// TODO: optimize 
		//var arg1:Vector<Int> = new Vector<Int>();
		//var callback:Vector<Int->PARAM->Void> = new Vector<Int->PARAM->Void>();
		var arg1:Array<Int> = new Array<Int>();
		var callback:Array<Int->PARAM->Void> = new Array<Int->PARAM->Void>();
		
		node = head;
		
		while (node != null) // TODO - optimize: counter for priority
		{	
			if (node.node.event_nr == event_nr)
			{
				callback.push(node.node.callback);
				arg1.push(node.node.event_nr);
			}
			node = node.next;
		}

		for (i in 0...callback.length)
		{
			callback[i](arg1[i], send_params);
		}

	}
	
	public inline function listen(obs:PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>, event_nr:Int, callback:Int->PARAM->Void, checkEventExists:Bool):Void
	{
		// check if event is still listening !!!
		if (checkEventExists) unlisten(obs, event_nr);
		var obsNode:PeoteDLLNode<PeoteDLLNode<PeoteEventNode<PARAM>>> = obs.append(append( new PeoteEventNode(null, callback, event_nr) )); 
		obsNode.node.node.listen = obsNode;		
	}
	
	public inline function unlisten(obs:PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>, event_nr:Int):Void
	{
		node = head;
		while (node != null)
		{	
			if (node.node.listen.dll == obs && node.node.event_nr == event_nr)
			{	
					obs.unlink(node.node.listen);
					node = unlink(node);
			}
			else node = node.next;
		}
	}
	
	public inline function unlistenObj(obs:PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>):Void
	{
		obsnode = obs.head; // TODO: optimize
		while (obsnode != null)
		{	
			if (obsnode.node.dll == this)
			{
				this.unlink(obsnode.node);
				obsnode = obs.unlink(obsnode);
			}
			else obsnode = obsnode.next;
		}
	}
	
/*	public inline function unlistenAll(obs:PeoteDLL<PeoteDLLNode<PeoteEventNode<PARAM>>>):Void
	{
		obsnode = obs.head;
		while (obsnode != null)
		{	
			obsnode.node.dll.unlink(obsnode.node);
			obsnode = obsnode.next;
			//obsnode = obsnode.nextClear(); // GC-optimization
		}
		obs.head = null;
	}
*/	
	public inline function removeAllListener():Void
	{	
		node = head;
		while (node != null)
		{	
			node.node.listen.dll.unlink(node.node.listen);
			node = node.next; 
		}
		head = null;
	}
	
	

}



