/* Decompressor
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-11-26
 */
MACHINE Decompressor

SEES DecompConstants,
     Strings

VARIABLES input,
          written_index,
          output,
          error_occurred

INVARIANT input: ABSTRACT_STRINGS &
          output: BYTE_STRINGS &
          written_index: NATURAL &
          error_occurred: BOOL &
          (decomp(input))'RESULT = output &
          (decomp(input))'ERROR = error_occurred &
          written_index <= size(output)

INITIALISATION input := <> || written_index := 0 || output := <> || error_occurred := FALSE
    
OPERATIONS
    put_atom(tag,pp,ll,qq) = 
        PRE tag:TAGS &
            pp: NAT &
            ll: NAT &
            qq: 0..max_quote_length --> BYTE &
            rec(TAG:tag,POINTER:pp,LENGTH:ll,QUOTE:qq): ATOMS
        THEN
            LET aa BE aa = rec(TAG:tag,POINTER:pp,LENGTH:ll,QUOTE:qq)
            IN
                ANY ms WHERE ms: MAYBE_STRINGS & 
                             ms = decomp_atom(aa, output)
                THEN
                    input := input <- aa
                   || output := output ^ ms'RESULT
                   || error_occurred := bool(error_occurred = TRUE or ms'ERROR = TRUE)
                END
            END
        END;
    tt <-- ready = tt := bool(written_index < size(output));
    tt <-- error_status = tt := error_occurred;                           
    bb <-- read_byte = PRE written_index < size(output)
                       THEN
                           bb := output(written_index + 1)
                           || written_index := written_index + 1
                       END
END 