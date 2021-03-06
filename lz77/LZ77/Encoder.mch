/* Encoder
 * Author: 
 * Creation date: 2013-12-05
 */
MACHINE Encoder
SEES EncodeConstants,
     Strings

CONSTANTS enc_max_waiting
    
PROPERTIES enc_max_waiting: NAT &
           1 + pointer_nbytes + runlength_nbytes <= enc_max_waiting &
           1 + quote_length_nbytes + max_quote_length <= enc_max_waiting
     
VARIABLES enc_input,
          enc_output,
          enc_written_index
INVARIANT enc_input: ABSTRACT_STRINGS &
          enc_output: BYTE_STRINGS &
          enc_written_index: NATURAL &
          enc_written_index <= size(enc_output) &
          size(enc_output) - enc_written_index <= enc_max_waiting
          
INITIALISATION enc_input := <> 
               || enc_output := <> 
               || enc_written_index := 0
OPERATIONS 
    enc_put_atom(tag,pp,ll,qqlen,qq) = 
        PRE tag: TAGS &
            pp:  0..max_pointer &
            ll:  0..max_runlength &
            qqlen: 0..max_quote_length &
            qq: 0..max_quote_length --> 0..255 &
            rec(TAG:tag,POINTER:pp,RUNLENGTH:ll,QUOTE_LEN:qqlen,QUOTE:qq): ATOMS &
            (tag = Lit => pp = 0 & ll = 0) &
            (tag = Ref => pp /= 0  & ll /= 0 & qq = <>) &
            size(enc_output) - enc_written_index = 0
        THEN
            enc_input := enc_input <- rec(TAG:tag,POINTER:pp,RUNLENGTH:ll,QUOTE_LEN:qqlen,QUOTE:qq)
            || IF tag = Lit
               THEN ANY bs WHERE bs: BYTE_STRINGS &
                                 bs = encode_quote_length(size(qq))
                    THEN 
                        enc_output := enc_output ^ [lit_code] ^ bs ^ ((1..qqlen)<|qq)
                    END
               ELSE ANY bs1,bs2 WHERE bs1: BYTE_STRINGS &
                                      bs2: BYTE_STRINGS &
                                      bs1 = encode_pointer(pp) &
                                      bs2 = encode_runlength(ll)
                    THEN
                        enc_output := enc_output ^ [ref_code] ^ bs1 ^ bs2
                    END
               END
        END;
tt <-- enc_ready = tt := bool(enc_written_index < size(enc_output));
bb <-- enc_read_byte = PRE enc_written_index < size(enc_output)
                   THEN bb := enc_output(enc_written_index + 1)
                        || enc_written_index := enc_written_index + 1
                   END
END
