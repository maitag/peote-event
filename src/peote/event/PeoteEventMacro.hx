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
	public static function build(...arguments:Expr):Array<Field>
	{
		var listen = new Array<{type:ComplexType, param:ComplexType, postfix:String}>();
		var fields = Context.getBuildFields();
		
		var cl = Context.getLocalClass().get();
		trace("-------"+cl.name+"-------");
		//trace(cl.params);
		
		var paramType:ComplexType;
		var classType:ComplexType = paramType = TypeTools.toComplexType(Context.getLocalType());
		var postfix:String = "";
		
		if (arguments.length == 0)
		{
			//trace(paramType);
			//listen.push({type:paramType, param:paramType, postfix:"" });
			
			fields = buildListeners(fields, "", "", classType, paramType, postfix);
			fields = buildSenders(fields, "", "", classType, paramType, postfix);
			
		}
		else 
		{
			for (arg in arguments)
			{
				var args:String = new Printer().printExpr(arg);
				trace( args  );
				
				paramType = TypeTools.toComplexType(Context.getLocalType());
				var paramRegExp = ~/param\s*:\s*([\w]+)/;
				if (paramRegExp.match(args)) {
					trace(" param:" + paramRegExp.matched(1));
					paramType = TPath({ name:paramRegExp.matched(1), pack:[], params:[] });
				}
				
				postfix = "";
				var postfixRegExp = ~/postfix\s*:\s*"?([\w]+)"?/;
				if (postfixRegExp.match(args)) {
					postfix = postfixRegExp.matched(1);
				}
				
				var listenRegExp = ~/listen\s*:\s*([\w]+)/;
				var sendRegExp = ~/send\s*:\s*([\w]+)/;
				if (listenRegExp.match(args)) {
					trace(' listenEvent$postfix to type:' + listenRegExp.matched(1));
					fields = buildListeners(fields, listenRegExp.matched(1), cl.name,
						TPath({ name:listenRegExp.matched(1), pack:[], params:[] }), paramType, postfix);
				}
				else if (sendRegExp.match(args)) {
					trace(' sendEvent$postfix to type:' + sendRegExp.matched(1));
					fields = buildSenders(fields, cl.name, sendRegExp.matched(1),
						TPath({ name:sendRegExp.matched(1), pack:[], params:[] }), paramType, postfix);
				}
				else {
					trace(' listenEvent$postfix and sendEvent$postfix for own type');
					fields = buildListeners(fields, "", "", classType, paramType, postfix);
					fields = buildSenders(fields, "", "", classType, paramType, postfix);
				}
				
				
			}
			
			var paramType:ComplexType = TPath({ name:"Param", pack:[], params:[] });
			var classType:ComplexType = TPath({ name:"IPeoteEventParam", pack:[], params:[] });
			
			
		
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
					//{name:"sender", type:macro:IPeoteEvent<$paramType>}, // TODO: only the Interface on need
					{name:"sender", type:macro:$classType}, // TODO: only the Interface on need
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
					//{name:"sender", type:macro:IPeoteEvent<$paramType>}, // TODO: only the Interface on need
					{name:"sender", type:macro:$classType}, // TODO: only the Interface on need
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
				//args:[ {name:"sender", type:macro:IPeoteEvent<$paramType>} ], // TODO: only the Interface on need
				args:[ {name:"sender", type:macro:$classType} ], // TODO: only the Interface on need				
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
				       {name:"timeslicer", type:macro:PeoteTimeslicer<$paramType>},
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
				//args:[ {name:"listener", type:macro:IPeoteEvent<$paramType>} ], // TODO: only the Interface on need
				args:[ {name:"listener", type:macro:$classType} ], // TODO: only the Interface on need				
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
	
	
	
/*	
	public static function build(param:ExprOf<ComplexType>):Array<Field>
	{
		var paramPack = new Printer().printExpr(param).split(".");
		//trace(paramPack);
		
		if (paramPack.length == 0) Context.error("Param Type expected", Context.currentPos());		
		var paramName = paramPack.pop();
				
		var paramType:ComplexType = TPath({ name:paramName, pack:paramPack, params:[] });
				
		var fields = Context.getBuildFields();
				
		// ----- adding the interface vars -------
		
		fields.push({
			name:  "observed_by",
			access:  [Access.APrivate],
			kind: FieldType.FVar( macro:PeoteEventDLL<$paramType>, macro new PeoteEventDLL<$paramType>() ), 
			pos: Context.currentPos(),
		});
		
		fields.push({
			name:  "observe",
			access:  [Access.APrivate],
			kind: FieldType.FVar( macro:PeoteDLL<PeoteDLLNode<PeoteEventNode<$paramType>>>, macro new PeoteDLL<PeoteDLLNode<PeoteEventNode<$paramType>>>() ), 
			pos: Context.currentPos(),
		});
		
		// ----- adding the interface functions -----
		
		fields.push({
			name: "sendEvent",
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"event", type:macro:Int},
				       {name:"params", type:macro:$paramType, opt:true, value:null}
				],
				expr: macro observed_by.send(event, params),
				ret: null
			})
		});
		
		fields.push({
			name: "sendTimeEvent",
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"event", type:macro:Int},
				       {name:"params", type:macro:$paramType, opt:true, value:null},
				       {name:"timeslicer", type:macro:PeoteTimeslicer<$paramType>},
				       {name:"delay", type:macro:Float, opt:false, value:macro 0.0}
				],
				expr: macro timeslicer.push(delay, observed_by, event, params),
				ret: null
			})
		});
		
		fields.push({
			name: "listenEvent",
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"sender", type:macro:IPeoteEvent<$paramType>}, // TODO: only the Interface on need
				       {name:"event", type:macro:Int},
				       {name:"callback", type:macro:Int->$paramType->Void, opt:true, value:null},
				       {name:"checkEventExists", type:macro:Bool, opt:false, value:macro true}
				],
				expr: macro sender.observed_by.listen(observe, event, callback, checkEventExists),
				ret: null
			})
		});
		
		fields.push({
			name: "unlistenEvent",
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"sender", type:macro:IPeoteEvent<$paramType>}, // TODO: only the Interface on need
				       {name:"event", type:macro:Int}
				],
				expr: macro sender.observed_by.unlisten(observe, event),
				ret: null
			})
		});
		
		fields.push({
			name: "unlistenFrom",
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"sender", type:macro:IPeoteEvent<$paramType>} // TODO: only the Interface on need
				],
				expr: macro sender.observed_by.unlistenObj(observe),
				ret: null
			})
		});
		
		fields.push({
			name: "unlistenAll",
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[],
				expr: macro observed_by.unlistenAll(observe),
				ret: null
			})
		});
	

		fields.push({
			name: "removeListener",
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"listener", type:macro:IPeoteEvent<$paramType>} // TODO: only the Interface on need
				],
				expr: macro observed_by.unlistenObj(listener.observe),
				ret: null
			})
		});
	

		fields.push({
			name: "removeAllListener",
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[],
				expr: macro observed_by.removeAllListener(),
				ret: null
			})
		});
	

		return fields;
		
	}
*/	
}

#end