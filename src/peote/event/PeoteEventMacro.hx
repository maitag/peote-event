package peote.event;

/**
 * by Sylvio Sell - rostock 2023
 */

#if macro // ------- macro land ---------

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Printer;
import haxe.macro.TypeTools;

class PeoteEventMacro
{	
	static var postfixRegExp = ~/postfix\s*:\s*"?([\w]+)"?/;
	
	static var paramRegExp = ~/param\s*:\s*([\w\.]+)/;
	static var typeRegExp = ~/type\s*:\s*([\w\.]+)/;
	static var listenRegExp = ~/listen\s*:\s*([\w\.]+)/;
	static var sendRegExp = ~/send\s*:\s*([\w\.]+)/;
	
	// only for one argument {type:..., param:.., postfix: ...}
	public static function build(arg:Expr):Array<Field> {
		var args:String = new Printer().printExpr(arg);
		
		var fields = Context.getBuildFields();
		
		var cl = Context.getLocalClass().get();
		trace("------- " + cl.name+" -------");
		
		var paramType:ComplexType;
		var classType:ComplexType = paramType = TypeTools.toComplexType(Context.getLocalType());
		var postfix = "";
		
		if (typeRegExp.match(args)) {
			trace("type:" + typeRegExp.matched(1));
			var p = typeRegExp.matched(1).split(".");
			var n = p.pop();
			classType = TPath({ name:n, pack:p, params:[] });
		}
		
		if (paramRegExp.match(args)) {
			trace("param:" + paramRegExp.matched(1));
			var p = paramRegExp.matched(1).split(".");
			var n = p.pop();
			paramType = TPath({ name:n, pack:p, params:[] });
		}
		
		if (postfixRegExp.match(args)) {
			trace("postfix:" + postfixRegExp.matched(1));
			postfix = postfixRegExp.matched(1);
		}
		
		fields = buildListeners(fields, "", "", classType, paramType, postfix);
		fields = buildSenders(fields, "", "", classType, paramType, postfix);			
		return fields;
		
	}

	// multiple arguments:  {listen:TYPE, param:TYPE, postfix:""}, {send:TYPE, param:TYPE, postfix:""}
	public static function buildMulti(...arguments:Expr):Array<Field>
	{
		var fields = Context.getBuildFields();
		
		var cl = Context.getLocalClass().get();
		trace("------- " + cl.name+" -------");
		
		var paramType:ComplexType;
		var classType:ComplexType = paramType = TypeTools.toComplexType(Context.getLocalType());
		var postfix:String = "";
		
		if (arguments.length == 0) {
			throw('Need arguments for PeoteEventMacro.buildMulti! Have to be into format: {listen:TYPE, param:TYPE, postfix:""}, {send:TYPE, param:TYPE, postfix:""}, ...');
		}
		else {
			for (arg in arguments)
			{
				var args:String = new Printer().printExpr(arg);
								
				postfix = "";
				if (postfixRegExp.match(args)) {
					postfix = postfixRegExp.matched(1);
				}
				
				if (listenRegExp.match(args)) {
					var p = listenRegExp.matched(1).split(".");
					var n = p.pop();

					if (paramRegExp.match(args)) {
						var p = paramRegExp.matched(1).split(".");
						var n = p.pop();
						paramType = TPath({ name:n, pack:p, params:[] });
					}
					else paramType = classType;
					
					trace(' listenEvent$postfix, type:' + listenRegExp.matched(1) + ", param:" + ((paramRegExp.matched(1) != null) ? paramRegExp.matched(1) : n));					
					fields = buildListeners(fields, n, cl.name, TPath({ name:n, pack:p, params:[] }), paramType, postfix);
				}
				else if (sendRegExp.match(args)) {
					var p = sendRegExp.matched(1).split(".");
					var n = p.pop();
					
					if (paramRegExp.match(args)) {
						var p = paramRegExp.matched(1).split(".");
						var n = p.pop();
						paramType = TPath({ name:n, pack:p, params:[] });
					}
					else paramType = TPath({ name:n, pack:p, params:[] });
					
					trace(' sendEvent$postfix, type:' + sendRegExp.matched(1) + ", param:" + ((paramRegExp.matched(1) != null) ? paramRegExp.matched(1) : n));					
					fields = buildSenders(fields, cl.name, n, TPath({ name:n, pack:p, params:[] }), paramType, postfix);
				}
				else throw('Argument-error for PeoteEventMacro.buildMulti! Have to be into format: {listen:TYPE, param:TYPE, postfix:""} or {send:TYPE, param:TYPE, postfix:""}');
				
			}
			
		}
				
		return fields;
	}
	
	
	// --------------------- generate Listeners -------------------------

	static function buildListeners(fields:Array<Field>, obsName:String, obsByName:String, classType:ComplexType, paramType:ComplexType, postfix:String):Array<Field>
	{		
		fields.push({
			name:  "observe"+obsName,
			access:  [Access.APublic],
			//access:  [Access.APrivate],
			kind: FieldType.FVar( macro:peote.event.PeoteDLL<peote.event.PeoteDLLNode<peote.event.PeoteEventNode<$paramType>>>, macro new peote.event.PeoteDLL<peote.event.PeoteDLLNode<peote.event.PeoteEventNode<$paramType>>>() ), 
			pos: Context.currentPos(),
		});
		
		fields.push({
			name: "listenEvent"+postfix,
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ 
					{name:"sender", type:macro:$classType},
					{name:"event", type:macro:Int},
					{name:"callback", type:macro:Int->$paramType->Void, opt:true, value:null},
					{name:"checkEventExists", type:macro:Bool, opt:false, value:macro true}
				],
				//expr: macro sender.observed_by.listen(observe, event, callback, checkEventExists),
				expr: Context.parse('sender.observed_by${obsByName}.listen(observe${obsName}, event, callback, checkEventExists)', Context.currentPos()),
				ret: null
			})
		});
		
		fields.push({
			name: "unlistenEvent"+postfix,
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ 
					{name:"sender", type:macro:$classType},
					{name:"event", type:macro:Int}
				],
				//expr: macro sender.observed_by.unlisten(observe, event),
				expr: Context.parse('sender.observed_by${obsByName}.unlisten(observe${obsName}, event)', Context.currentPos()),
				ret: null
			})
		});
		
		fields.push({
			name: "unlistenFrom"+postfix,
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"sender", type:macro:$classType} ],			
				//expr: macro sender.observed_by.unlistenObj(observe),
				expr: Context.parse('sender.observed_by${obsByName}.unlistenObj(observe${obsName})', Context.currentPos()),
				ret: null
			})
		});
		
		// TODO: 
		fields.push({
			name: "unlistenAll"+postfix,
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[],
				//expr: macro observed_by.unlistenAll(observe),
/*				expr: macro {
					var obsnode = observe.head;
					while (obsnode != null)
					{	
						obsnode.node.dll.unlink(obsnode.node);
						obsnode = obsnode.next;
						//obsnode = obsnode.nextClear(); // GC-optimization
					}
					observe.head = null;					
				},
*/				expr: Context.parse('
					var obsnode = observe${obsName}.head;
					while (obsnode != null) {	
						obsnode.node.dll.unlink(obsnode.node);
						obsnode = obsnode.next;
						//obsnode = obsnode.nextClear(); // GC-optimization
					}
					observe${postfix}.head = null;					
				', Context.currentPos()),
				ret: null
			})
		});
		
		return fields;
	}
	
	// --------------------- generate Senders -------------------------

	static function buildSenders(fields:Array<Field>, obsName:String, obsByName:String, classType:ComplexType, paramType:ComplexType, postfix:String):Array<Field>
	{
		
		fields.push({
			name:  "observed_by"+obsByName,
			//access:  [Access.APrivate],
			access:  [Access.APublic],
			kind: FieldType.FVar( macro:peote.event.PeoteEventDLL<$paramType>, macro new peote.event.PeoteEventDLL<$paramType>() ), 
			pos: Context.currentPos(),
		});
		
		fields.push({
			name: "sendEvent"+postfix,
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"event", type:macro:Int},
				       {name:"params", type:macro:$paramType, opt:true, value:null}
				],
				//expr: macro observed_by.send(event, params),
				expr: Context.parse('observed_by${obsByName}.send(event, params)', Context.currentPos()),
				ret: null
			})
		});
		
		fields.push({
			name: "sendTimeEvent"+postfix,
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"event", type:macro:Int},
				       {name:"params", type:macro:$paramType, opt:true, value:null},
				       {name:"timeslicer", type:macro:peote.event.PeoteTimeslicer<$paramType>},
				       {name:"delay", type:macro:Float, opt:false, value:macro 0.0}
				],
				//expr: macro timeslicer.push(delay, observed_by, event, params),
				expr: Context.parse('timeslicer.push(delay, observed_by${obsByName}, event, params)', Context.currentPos()),
				ret: null
			})
		});
		
		fields.push({
			name: "removeListener"+postfix,
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"listener", type:macro:$classType} ],				
				//expr: macro observed_by.unlistenObj(listener.observe),
				expr: Context.parse('observed_by${obsByName}.unlistenObj(listener.observe${obsName})', Context.currentPos()),
				ret: null
			})
		});
	

		fields.push({
			name: "removeAllListener"+postfix,
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[],
				//expr: macro observed_by.removeAllListener(),
				expr: Context.parse('observed_by${obsByName}.removeAllListener()', Context.currentPos()),
				ret: null
			})
		});
		
		return fields;
	}
	
}

#end