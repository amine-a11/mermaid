/** mermaid
 *  https://mermaidjs.github.io/
 *  (c) 2014-2015 Knut Sveidqvist
 *  MIT license.
 *
 *  Based on js sequence diagrams jison grammr
 *  http://bramp.github.io/js-sequence-diagrams/
 *  (c) 2012-2013 Andrew Brampton (bramp.net)
 *  Simplified BSD license.
 */
%lex

%options case-insensitive

// Special states for recognizing aliases
%x ID
%x STATE
%x FORK_STATE
%x STATE_STRING
%x STATE_ID
%x ALIAS
%x SCALE
%x NOTE
%x NOTE_ID
%x NOTE_TEXT
%x FLOATING_NOTE
%x FLOATING_NOTE_ID
%x struct

// A special state for grabbing text up to the first comment/newline
%x LINE

%%

[\n]+                            return 'NL';
\s+                              /* skip all whitespace */
<ID,STATE,struct,LINE>((?!\n)\s)+       /* skip same-line whitespace */
<INITIAL,ID,STATE,struct,LINE>\#[^\n]*  /* skip comments */
\%%[^\n]*                        /* skip comments */

"scale"\s+            { this.pushState('SCALE'); console.log('Got scale', yytext);return 'scale'; }
<SCALE>\d+            return 'WIDTH';
<SCALE>\s+"width"     {this.popState();}

<INITIAL,struct>"state"\s+            { this.pushState('STATE'); }
<STATE>.*"<<fork>>"                   {this.popState();console.log('Fork: ',yytext);return 'FORK';}
<STATE>.*"<<join>>"                   {this.popState();console.log('Join: ',yytext);return 'JOIN';}
<STATE>["]                   this.begin("STATE_STRING");
<STATE>"as"\s*         {this.popState();this.pushState('STATE_ID');return "AS";}
<STATE_ID>[^\n\{]*         {this.popState();console.log('STATE_ID', yytext);return "ID";}
<STATE_STRING>["]              this.popState();
<STATE_STRING>[^"]*         { console.log('Long description:', yytext);return "STATE_DESCR";}
<STATE>[^\n\s\{]+      {console.log('COMPOSIT_STATE', yytext);return 'COMPOSIT_STATE';}
<STATE>\n      {this.popState();}
<INITIAL,STATE>\{               {this.popState();this.pushState('struct'); console.log('begin struct', yytext);return 'STRUCT_START';}
<struct>\}           { console.log('Ending struct'); this.popState(); return 'STRUCT_STOP';}}
<struct>[\n]              /* nothing */

<INITIAL,struct>"note"\s+           { this.begin('NOTE'); return 'note'; }
<NOTE>"left of"                     { this.popState();this.pushState('NOTE_ID');console.log('Got dir');return 'left_of';}
<NOTE>"right of"                    { this.popState();this.pushState('NOTE_ID');return 'right_of';}
<NOTE>\"                            { this.popState();this.pushState('FLOATING_NOTE');}
<FLOATING_NOTE>\s*"as"\s*       {this.popState();this.pushState('FLOATING_NOTE_ID');return "AS";}
<FLOATING_NOTE>["]         /**/
<FLOATING_NOTE>[^"]*         { console.log('Floating note text: ', yytext);return "NOTE_TEXT";}
<FLOATING_NOTE_ID>[^\n]*         {this.popState();console.log('Floating note ID', yytext);return "ID";}
<NOTE_ID>\s*[^:\n\s\-]+                { this.popState();this.pushState('NOTE_TEXT');console.log('Got ID for note', yytext);return 'ID';}
<NOTE_TEXT>\s*":"[^\+\-:\n,;]+       { this.popState();console.log('Got NOTE_TEXT for note',yytext);return 'NOTE_TEXT';}
<NOTE_TEXT>\s*[^\+\-:,;]+"end note"       { this.popState();console.log('Got NOTE_TEXT for note',yytext);return 'NOTE_TEXT';}

"stateDiagram"\s+                   { console.log('Got state diagram', yytext,'#');return 'SD'; }
"hide empty description"    { console.log('HIDE_EMPTY', yytext,'#');return 'HIDE_EMPTY'; }
<INITIAL,struct>"[*]"                   { console.log('EDGE_STATE=',yytext); return 'EDGE_STATE';}
<INITIAL,struct>[^:\n\s\-\{]+                { console.log('=>ID=',yytext); return 'ID';}
<INITIAL,struct>\s*":"[^\+\->:\n,;]+      { yytext = yytext.trim(); console.log('Descr = ', yytext); return 'DESCR'; }
<INITIAL,struct>"-->"             return '-->';
<struct>"--"        return 'CONCURRENT';
<<EOF>>           return 'NL';
.                 return 'INVALID';

/lex

%left '^'

%start start

%% /* language grammar */

start
	: SPACE start
	| NL start
	| SD document { return $2; }
	;

document
	: /* empty */ { $$ = [] }
	| document line {$1.push($2);$$ = $1}
	;

line
	: SPACE statement { console.log('here');$$ = $2 }
	| statement {console.log('line', $1); $$ = $1 }
	| NL { $$=[];}
	;

statement
	: idStatement DESCR
	| idStatement '-->' idStatement {yy.addRelation($1, $3);}
	| idStatement '-->' idStatement DESCR
    | HIDE_EMPTY
    | scale WIDTH
    | COMPOSIT_STATE
    | COMPOSIT_STATE STRUCT_START document STRUCT_STOP
    | STATE_DESCR AS ID
    | STATE_DESCR AS ID STRUCT_START document STRUCT_STOP
    | FORK
    | JOIN
    | CONCURRENT
    | note notePosition ID NOTE_TEXT
    | note NOTE_TEXT AS ID
    ;

idStatement
    : ID {$$=$1;}
    | EDGE_STATE {$$=$1;}
    ;

notePosition
    : left_of
    | right_of
    ;
// statement
// 	: 'participant' actor 'AS' restOfLine 'NL' {$2.description=$4; $$=$2;}
// 	| 'participant' actor 'NL' {$$=$2;}
// 	| signal 'NL'
// 	| 'activate' actor 'NL' {$$={type: 'activeStart', signalType: yy.LINETYPE.ACTIVE_START, actor: $2};}
// 	| 'deactivate' actor 'NL' {$$={type: 'activeEnd', signalType: yy.LINETYPE.ACTIVE_END, actor: $2};}
// 	| note_statement 'NL'
// 	| title text2 'NL' {$$=[{type:'setTitle', text:$2}]}
// 	| 'loop' restOfLine document end
// 	{
// 		$3.unshift({type: 'loopStart', loopText:$2, signalType: yy.LINETYPE.LOOP_START});
// 		$3.push({type: 'loopEnd', loopText:$2, signalType: yy.LINETYPE.LOOP_END});
// 		$$=$3;}
// 	| 'rect' restOfLine document end
// 	{
// 		$3.unshift({type: 'rectStart', color:$2, signalType: yy.LINETYPE.RECT_START });
// 		$3.push({type: 'rectEnd', color:$2, signalType: yy.LINETYPE.RECT_END });
// 		$$=$3;}
// 	| opt restOfLine document end
// 	{
// 		$3.unshift({type: 'optStart', optText:$2, signalType: yy.LINETYPE.OPT_START});
// 		$3.push({type: 'optEnd', optText:$2, signalType: yy.LINETYPE.OPT_END});
// 		$$=$3;}
// 	| alt restOfLine else_sections end
// 	{
// 		// Alt start
// 		$3.unshift({type: 'altStart', altText:$2, signalType: yy.LINETYPE.ALT_START});
// 		// Content in alt is already in $3
// 		// End
// 		$3.push({type: 'altEnd', signalType: yy.LINETYPE.ALT_END});
// 		$$=$3;}
// 	| par restOfLine par_sections end
// 	{
// 		// Parallel start
// 		$3.unshift({type: 'parStart', parText:$2, signalType: yy.LINETYPE.PAR_START});
// 		// Content in par is already in $3
// 		// End
// 		$3.push({type: 'parEnd', signalType: yy.LINETYPE.PAR_END});
// 		$$=$3;}
// 	;

// par_sections
// 	: document
// 	| document and restOfLine par_sections
// 	{ $$ = $1.concat([{type: 'and', parText:$3, signalType: yy.LINETYPE.PAR_AND}, $4]); }
// 	;

// else_sections
// 	: document
// 	| document else restOfLine else_sections
// 	{ $$ = $1.concat([{type: 'else', altText:$3, signalType: yy.LINETYPE.ALT_ELSE}, $4]); }
// 	;

// note_statement
// 	: 'note' placement actor text2
// 	{
// 		$$ = [$3, {type:'addNote', placement:$2, actor:$3.actor, text:$4}];}
// 	| 'note' 'over' actor_pair text2
// 	{
// 		// Coerce actor_pair into a [to, from, ...] array
// 		$2 = [].concat($3, $3).slice(0, 2);
// 		$2[0] = $2[0].actor;
// 		$2[1] = $2[1].actor;
// 		$$ = [$3, {type:'addNote', placement:yy.PLACEMENT.OVER, actor:$2.slice(0, 2), text:$4}];}
// 	;

// spaceList
//     : SPACE spaceList
//     | SPACE
//     ;
// actor_pair
// 	: actor ',' actor   { $$ = [$1, $3]; }
// 	| actor             { $$ = $1; }
// 	;

// placement
// 	: 'left_of'   { $$ = yy.PLACEMENT.LEFTOF; }
// 	| 'right_of'  { $$ = yy.PLACEMENT.RIGHTOF; }
// 	;

// signal
// 	: actor signaltype '+' actor text2
// 	{ $$ = [$1,$4,{type: 'addMessage', from:$1.actor, to:$4.actor, signalType:$2, msg:$5},
// 	              {type: 'activeStart', signalType: yy.LINETYPE.ACTIVE_START, actor: $4}
// 	             ]}
// 	| actor signaltype '-' actor text2
// 	{ $$ = [$1,$4,{type: 'addMessage', from:$1.actor, to:$4.actor, signalType:$2, msg:$5},
// 	             {type: 'activeEnd', signalType: yy.LINETYPE.ACTIVE_END, actor: $1}
// 	             ]}
// 	| actor signaltype actor text2
// 	{ $$ = [$1,$3,{type: 'addMessage', from:$1.actor, to:$3.actor, signalType:$2, msg:$4}]}
// 	;

// actor
// 	: ACTOR {$$={type: 'addActor', actor:$1}}
// 	;

// signaltype
// 	: SOLID_OPEN_ARROW  { $$ = yy.LINETYPE.SOLID_OPEN; }
// 	| DOTTED_OPEN_ARROW { $$ = yy.LINETYPE.DOTTED_OPEN; }
// 	| SOLID_ARROW       { $$ = yy.LINETYPE.SOLID; }
// 	| DOTTED_ARROW      { $$ = yy.LINETYPE.DOTTED; }
// 	| SOLID_CROSS       { $$ = yy.LINETYPE.SOLID_CROSS; }
// 	| DOTTED_CROSS      { $$ = yy.LINETYPE.DOTTED_CROSS; }
// 	;

// text2: TXT {$$ = $1.substring(1).trim().replace(/\\n/gm, "\n");} ;

%%
