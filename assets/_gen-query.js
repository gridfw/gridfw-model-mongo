// GENERATE QUERY INTERFACES
function _genQuery(generator, args){
	var argCount= Object.keys(args).length;
	// check arguments
	var fx= [
		null,
		`\n\t\tthrow new Error 'Expected ${argCount} arguments' unless arguments.length is ${argCount}`
	];
	var genArgs= [];
	for(var k in args){
		var v= args[k];
		genArgs.push(k);
		fx.push(`\n\t\tthrow new Error '${k} expected ${v}' unless (typeof ${k} is 'object' and ${k}.hasOwnProperty 'toJSON') or `);
		switch(v){
			case 'plainObject':
				fx.push(`typeof ${k} is 'object' and not Array.isArray ${k}`);
				break;
			case 'array':
				fx.push(`Array.isArray ${k}`);
				break;
			default:
				fx.push(`typeof ${k} is '${v}'`);
		}
			
	}
	// create query
	genArgs= genArgs.join(', ');
	fx[0]= `(${genArgs})->`;
	fx.push(`\n\t\tnew ${generator} this, ${genArgs}`);
	// return fx
	return fx.join('');
}