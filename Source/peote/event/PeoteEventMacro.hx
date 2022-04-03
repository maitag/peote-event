package peote.event;

#if !macro
//class PeoteEventMacro {}

#else // ------- macro land ---------

import haxe.Log;
import haxe.ds.StringMap;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;
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
		
/*		
		switch (Context.getLocalType()) {
			case TInst(n, []):
						var g = n.get();
						trace(g);
						var superName:String = null;
						var superModule:String = null;
						var s = g;
						while (s.superClass != null) {
							s = s.superClass.t.get(); trace("->" + s.name);
							superName = s.name;
							superModule = s.module;
						}
						if (s.interfaces != null) {
							for (i in s.interfaces) {
								trace (i.t.get());
								trace (i.params[0]);
								p = i.params;
								switch (i.params[0]) {
									case TInst(n, []):trace(n);
										paramType = TypeTools.toComplexType(i.params[0]);
										trace(paramType);
									default:
								}
							}
						}
						
						//return buildClass("Buffer",  g.pack, g.module, g.name, superModule, superName, TypeTools.toComplexType(t) );
			default: Context.error("Class expected", Context.currentPos());
		}
*/		
		var fields = Context.getBuildFields();
				
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
		
		fields.push({
			name: "sendEvent",
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[ {name:"event", type:macro:Int},
				       {name:"params", type:macro:$paramType, opt:true, value:null}
				],
				expr: macro {
					observed_by.send(event, params);
				},
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
				expr: macro {
					sender.observed_by.listen(observe, event, callback, checkEventExists);
				},
				ret: null
			})
		});
		
/*		fields.push({
			name: "unlistenAll",
			access: [Access.APublic, Access.AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args:[],
				expr: macro observed_by.unlistenAll(observe),
				ret: null
			})
		});
*/		

		return fields;
		
	}
}

#end