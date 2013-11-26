/* Decompressor
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-11-26
 */
MACHINE Decompressor

SEES DecompConstants,
     Strings

VARIABLES input,
          output_buffer,
          written,
          error_occurred

INVARIANT input: ABSTRACT_STRINGS &
          output_buffer: BYTE_STRINGS &
          written: BYTE_STRINGS &
          error_occurred: BOOL
          /* and more! */

INITIALISATION input := <> || output_buffer := <> || written := <> || error_occurred := FALSE
    
OPERATIONS
    put_atom(aa) = 
        PRE aa: ATOMS
        THEN
           ANY ms WHERE ms: MAYBE_STRINGS & 
                        ms = decomp_atom(aa, written^output_buffer)
                        /* Optionally, require ms'ERROR = FALSE in precondition.
                           We'll decide later. */
           THEN
             input := input <- aa 
             || output_buffer := output_buffer ^ ms'RESULT
             || error_occurred := ms'ERROR
           END
        END;
    tt <-- ready = IF output_buffer = <> 
                   THEN
                       tt := FALSE
                   ELSE
                        tt := TRUE
                   END;
    tt <-- error_status = tt := error_occurred;                           
    bb <-- read_byte = PRE output_buffer /= <>
                       THEN
                           bb := first(output_buffer)
                           || output_buffer := tail(output_buffer)
                           || written := written <- first(output_buffer)
                       END
END 