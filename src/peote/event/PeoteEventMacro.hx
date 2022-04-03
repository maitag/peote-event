package peote.event;

#if macro // ------- macro land ---------

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Printer;

class PeoteEventMacro
{
	public static function build(param:Expr)
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
}

#end