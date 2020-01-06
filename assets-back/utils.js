// /**
//  * Compilation utils
//  */

// var _ASSERT_TYPES= {
// 		// basic types
// 		object: "typeof argv is 'object' and argv",
// 		'function': "typeof argv is 'function'",
// 		string: "typeof argv is 'string'",
// 		number: "typeof argv is 'number'",
// 		boolean: "typeof argv is 'boolean'",
// 		symbol: "typeof argv is 'symbol'",
// 		// custom
// 		'plain object': "typeof argv is 'object' and argv and not Array.isArray argv",
// 		int: "Number.isSafeInteger argv",
// 		unsigned: "Number.isSafeInteger(argv) and argv>=0"
// 	};

// function assertArgTypes(fxName){
// 	var argc = arguments.length;
// 	var reqArgs= argc-1
// 	var code= [`throw new Error '${fxName}>> Expected ${reqArgs} arguments' unless arguments.length is ${reqArgs}`];
// 	var tp;
// 	for(var i=0; i<reqArgs; i++){
// 		tp = arguments[i+1];
// 		code.push(`argv=arguments[${i}]`);
// 		// one type
// 		if(typeof tp === 'string'){
// 			tpAssert= _ASSERT_TYPES[tp]
// 			if(tpAssert)
// 				code.push(`throw new Error "${fxName}>> Arguments[${i}] expected ${tp}" unless ${tpAssert}`);
// 			else
// 				throw new Error(`Unknown type: ${tp}`);
// 		}
// 		// mutiple possible types
// 		else
// 			tpAssert= tp.map(function(t){
// 				var t2= _ASSERT_TYPES[t];
// 				if(t2)
// 					return t2;
// 				else
// 					throw new Error(`Unknown type: ${t}`);
// 			}).join(') or (');
// 			code.push(`throw new Error "${fxName}>> Arguments[${i}] expected in [${tp.join(', ')}] " unless (${tpAssert})`);
// 	}
// 	return code.join("; ");
// }

