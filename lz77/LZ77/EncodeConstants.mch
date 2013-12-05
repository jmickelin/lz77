/* EncodeConstants
 * Author: 
 * Creation date: 2013-12-05
 */
MACHINE EncodeConstants
SEES Strings
ABSTRACT_CONSTANTS lit_code,
          ref_code,
          encode_quote_length,
          encode_pointer,
          encode_length,
          max_quote_length_nbytes,
          window_size_nbytes,
          lookahead_buffer_size_nbytes
PROPERTIES lit_code: BYTE &
           ref_code: BYTE &
           lit_code = 0 &
           ref_code = 1 &
           max_quote_length_nbytes: NAT &
           window_size_nbytes: NAT &
           lookahead_buffer_size_nbytes: NAT &
           2**(8*max_quote_length_nbytes) = max_quote_length &
           2**(8*window_size_nbytes) = window_size &
           2**(8*lookahead_buffer_size_nbytes) = lookahead_buffer_size &
           encode_quote_length: 1..max_quote_length --> { bs | bs: BYTE_STRINGS & 
                                                               size(bs) = max_quote_length_nbytes
                                                        } &
           encode_pointer: 1..window_size --> { bs | bs: BYTE_STRINGS &
                                                     size(bs) = window_size_nbytes
                                              } &
           encode_length: 1..lookahead_buffer_size --> { bs | bs: BYTE_STRINGS &
                                                              size(bs) = lookahead_buffer_size_nbytes
                                                       }
           
END
