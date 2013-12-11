/* Encoder
 * Author: 
 * Creation date: 2013-12-05
 */
MACHINE Encoder
SEES Strings, EncodeConstants
VARIABLES input,
          output,
          written_index
INVARIANT input: ABSTRACT_STRINGS &
          output: BYTE_STRINGS &
          written_index: NATURAL &
          written_index <= size(output)
INITIALISATION input := <> || output := <> || written_index := 0
OPERATIONS 
    put_atom(tag,pp,ll,qqlen,qq) = 
        PRE tag: TAGS &
            pp:  0..window_size &
            ll:  0..lookahead_buffer_size &
            qqlen: 0..max_quote_length &
            qq: 1..qqlen --> BYTE &
            rec(TAG:tag,POINTER:pp,LENGTH:ll,QUOTE:qq): ATOMS &
            (tag = Lit => pp = 0 & ll = 0) &
            (tag = Ref => pp /= 0  & ll /= 0 & qq = <>)
        THEN
            input := input <- rec(TAG:tag,POINTER:pp,LENGTH:ll,QUOTE:qq)
            || IF tag = Lit
               THEN ANY bs WHERE bs: BYTE_STRINGS &
                                 bs = encode_quote_length(size(qq))
                    THEN 
                        output := output ^ [lit_code] ^ bs ^ qq
                    END
               ELSE ANY bs1,bs2 WHERE bs1: BYTE_STRINGS &
                                      bs2: BYTE_STRINGS &
                                      bs1 = encode_pointer(pp) &
                                      bs2 = encode_length(ll)
                    THEN
                        output := output ^ [ref_code] ^ bs1 ^ bs2
                    END
               END
        END;
tt <-- ready = tt := bool(written_index < size(output));
bb <-- read_byte = PRE written_index < size(output)
                   THEN bb := output(written_index + 1)
                        || written_index := written_index + 1
                   END
END
