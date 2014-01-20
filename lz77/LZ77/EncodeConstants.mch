/* EncodeConstants
 * Author: 
 * Creation date: 2013-12-05
 */
MACHINE EncodeConstants
SEES Strings
CONCRETE_CONSTANTS
          quote_length_nbytes,
          pointer_nbytes,
          runlength_nbytes
ABSTRACT_CONSTANTS lit_code,
          ref_code,
          encode_quote_length,
          decode_quote_length,
          encode_pointer,
          decode_pointer,
          encode_runlength,
          decode_runlength
          
PROPERTIES lit_code: 0..255 &
           ref_code: 0..255 &
           lit_code = 0 &
           ref_code = 1 &
           quote_length_nbytes: NAT1 &
           pointer_nbytes: NAT1 &
           runlength_nbytes: NAT1 &
           /* */
           2**(8*quote_length_nbytes) = max_quote_length &
           2**(8*pointer_nbytes) = max_pointer &
           2**(8*runlength_nbytes) = max_runlength & 
           /* */ /* Remove these constraints and let the bijections do the work, for animation. */
           encode_quote_length: 1..max_quote_length >->> { bs | bs: BYTE_STRINGS & 
                                                                size(bs) = quote_length_nbytes
                                                         } &
           decode_quote_length = encode_quote_length~ &
           encode_pointer: 1..max_pointer >->> { bs | bs: BYTE_STRINGS &
                                                      size(bs) = pointer_nbytes
                                               } &
           decode_pointer = encode_pointer~ &
           encode_runlength: 1..max_runlength >->> { bs | bs: BYTE_STRINGS &
                                                          size(bs) = runlength_nbytes
                                                   } &
           decode_runlength = encode_runlength~
END
