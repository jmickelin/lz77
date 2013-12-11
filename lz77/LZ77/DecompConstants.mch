/* DecompConstants
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-11-26
 */
MACHINE DecompConstants

SEES Strings

ABSTRACT_CONSTANTS decomp, decomp1, decomp_atom
PROPERTIES
    decomp_atom : ATOMS * BYTE_STRINGS --> MAYBE_STRINGS &
    decomp_atom = % (aa,buf) . (aa: LITERALS & buf: BYTE_STRINGS |
                                rec(RESULT: aa'QUOTE,
                                    ERROR: FALSE))
                  <+
                  % (aa,buf) . (aa: REFERENCES & buf: BYTE_STRINGS & aa'POINTER <= size(buf) |
                                rec(RESULT:%nn . (nn : 1..(aa'LENGTH) | 
                                                  buf(size(buf) + 1 - (aa'POINTER) + ((nn - 1) mod (aa'POINTER)))),
                                    ERROR: FALSE))
                  <+
                  /* To make this a total function, we replace erroneous back-references
                     with the empty string.
                  */
                  % (aa,buf) . (aa: REFERENCES & buf: BYTE_STRINGS & aa'POINTER > size(buf) |
                                rec(RESULT: <>,
                                    ERROR: TRUE)) &
    decomp1 = %(as,ms1).(as:ABSTRACT_STRINGS & size(as) > 0 & ms1:MAYBE_STRINGS |
                         (tail(as), rec(RESULT:(ms1'RESULT ^ (decomp_atom(first(as), ms1'RESULT))'RESULT),
                                        ERROR:bool(ms1'ERROR=TRUE or 
                                                   (decomp_atom(first(as), ms1'RESULT))'ERROR=TRUE)))) & 
    decomp = {as,ms | as :ABSTRACT_STRINGS & 
                       ms : MAYBE_STRINGS &
                       (as=<> & ms=rec(RESULT: <>,ERROR: FALSE) or ((as,rec(RESULT:<>,ERROR:FALSE)),(<>,ms)) : closure1(decomp1))} 

ASSERTIONS
    decomp_atom : ATOMS * BYTE_STRINGS --> MAYBE_STRINGS &
    decomp : ABSTRACT_STRINGS --> MAYBE_STRINGS &
    (decomp(<>))'RESULT = <> &
    !(aa,as).(aa:ATOMS & as:ABSTRACT_STRINGS 
        => (decomp(as<-aa))'RESULT = (decomp(as))'RESULT ^ 
                                       (decomp_atom(aa,     
                                                    (decomp(as))'RESULT))'RESULT) &
    (decomp(<>))'ERROR = FALSE &
    !(aa,as).(aa:ATOMS & as:ABSTRACT_STRINGS 
        => (decomp(as<-aa))'ERROR = bool((decomp(as))'ERROR = TRUE or 
                                     (decomp_atom(aa,     
                                                  (decomp(as))'RESULT))'ERROR = TRUE))
END
