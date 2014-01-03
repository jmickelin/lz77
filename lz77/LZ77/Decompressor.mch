/* Decompressor
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-11-26
 */
MACHINE Decompressor

SEES DecompConstants,
     Strings

VARIABLES decomp_input,
          decomp_written_index,
          decomp_output,
          decomp_error_occurred

INVARIANT decomp_input: ABSTRACT_STRINGS &
          decomp_output: BYTE_STRINGS &
          decomp_written_index: NATURAL &
          decomp_error_occurred: BOOL &
          (decomp(decomp_input))'RESULT = decomp_output &
          (decomp(decomp_input))'ERROR = decomp_error_occurred &
          decomp_written_index <= size(decomp_output)

INITIALISATION decomp_input := <> 
               || decomp_written_index := 0 
               || decomp_output := <> 
               || decomp_error_occurred := FALSE
    
OPERATIONS
    decomp_put_atom(tag,pp,ll,qqlen,qq) = 
        PRE tag: TAGS &
            pp:  0..max_pointer &
            ll:  0..max_runlength &
            qqlen: 0..max_quote_length &
            qq: 1..qqlen --> BYTE &
            rec(TAG:tag,POINTER:pp,RUNLENGTH:ll,QUOTE:qq): ATOMS &
            (tag = Lit => pp = 0 & ll = 0) &
            (tag = Ref => pp /= 0  & ll /= 0 & qq = <>)
        THEN
            LET aa,ms BE aa = rec(TAG:tag,POINTER:pp,RUNLENGTH:ll,QUOTE:qq) &
                         ms = decomp_atom(aa, decomp_output)
            IN
                decomp_input := decomp_input <- aa
                || decomp_output := decomp_output ^ ms'RESULT
                || decomp_error_occurred := bool(decomp_error_occurred = TRUE or ms'ERROR = TRUE)
            END
        END;
    tt <-- decomp_ready = tt := bool(decomp_written_index < size(decomp_output));
    tt <-- decomp_error_status = tt := decomp_error_occurred;                           
    bb <-- decomp_read_byte = PRE decomp_written_index < size(decomp_output)
                       THEN
                           bb := decomp_output(decomp_written_index + 1)
                           || decomp_written_index := decomp_written_index + 1
                       END
END 