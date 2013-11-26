/* DecompConstants
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-11-26
 */
MACHINE DecompConstants

SEES Strings

ABSTRACT_CONSTANTS decomp, decomp_atom
PROPERTIES
    decomp_atom : ATOMS * BYTE_STRINGS <-> MAYBE_STRINGS &
    decomp_atom = 
        { aa,buf,ms | 
                      aa : ATOMS &
                      buf : BYTE_STRINGS &
                      ms : MAYBE_STRINGS &
                      # litstr . (litstr : BYTE_STRINGS &
                                  (aa = (Lit, 0, 0, litstr) => ms = rec(RESULT:litstr, 
                                                                        ERROR:FALSE))) &
                      # (pp,ll) . (pp : NAT &
                                   ll : NAT &
                                   (aa = (Ref, pp, ll, {0 |-> 0}) => 
                                       (pp < size(buf) 
                                           => ms = rec(RESULT:%nn . (nn : 0..(ll-1) | 
                                                             buf(size(buf) - pp + (nn mod pp))),
                                                       ERROR:FALSE)) &
                                       /* To make this a total function, we replace erroneous back-references
                                          with the empty string.
                                       */
                                       (pp >= size(buf)
                                           => ms = rec(RESULT:<>, 
                                                       ERROR:TRUE))))
        } &
    decomp : ABSTRACT_STRINGS <-> MAYBE_STRINGS &
    decomp = { as,ms | as :ABSTRACT_STRINGS & 
                       ms : MAYBE_STRINGS &
                       (as = <> => ms = rec(RESULT:<>,ERROR:FALSE)) &
                       (size(as) > 0 & front(as) : dom(decomp) 
                            => # ms1 . (ms1 : MAYBE_STRINGS &
                                       front(as) |-> ms1 : decomp &
                                       ms = rec(RESULT:(ms1'RESULT ^ (decomp_atom(last(as), ms1'RESULT))'RESULT),
                                                ERROR:bool(ms1'ERROR=TRUE or 
                                                           (decomp_atom(last(as), ms1'RESULT))'ERROR=TRUE))))
             }
ASSERTIONS
    decomp_atom : ATOMS * BYTE_STRINGS --> MAYBE_STRINGS &
    decomp : ABSTRACT_STRINGS --> MAYBE_STRINGS
END
