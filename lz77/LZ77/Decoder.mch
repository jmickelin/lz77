/* Decoder
 * Author: 
 * Creation date: 2013-12-08
 */
MACHINE Decoder
SEES Strings, EncodeConstants
VARIABLES input,
          output,
          decoded_index,
          written_index,
          error_occurred
INVARIANT input: BYTE_STRINGS &
          output: ABSTRACT_STRINGS &
          decoded_index: NATURAL &
          written_index: NATURAL &
          error_occurred: BOOL &
          
          written_index <= size(output) &
          decoded_index <= size(input)
          
INITIALISATION input := <>
               || output := <>
               || decoded_index := 0
               || written_index := 0
               || error_occurred := FALSE
OPERATIONS
    put_byte(bb) = 
        PRE bb: BYTE
        THEN
           input := input<- bb
           ||
           LET nondecoded, ref_size, lit_size BE
               nondecoded = (input<-bb)\|/decoded_index &
               ref_size = 1 + window_size_nbytes + lookahead_buffer_size_nbytes &
               lit_size = 1 + max_quote_length_nbytes 
                            + decode_quote_length((tail(nondecoded))/|\max_quote_length_nbytes)
           IN
              SELECT nondecoded(1) = ref_code THEN
                  IF size(nondecoded) = ref_size
                  THEN
                      LET pointer,length BE
                          pointer = tail(nondecoded)/|\window_size_nbytes &
                          length  = (tail(nondecoded)\|/window_size_nbytes)/|\lookahead_buffer_size_nbytes
                      IN
                          output := output <- rec(TAG:Ref,
                                                  POINTER:decode_pointer(pointer),
                                                  LENGTH:decode_length(length),
                                                  QUOTE:<>)
                          || decoded_index := size(input<-bb)
                      END
                  END
              WHEN nondecoded(1) = lit_code THEN
                  IF size(nondecoded) = lit_size
                  THEN
                      LET quote BE
                          quote = (tail(nondecoded))\|/max_quote_length_nbytes
                      IN 
                          output := output <- rec(TAG:Lit,
                                                  POINTER:0,
                                                  LENGTH: 0,
                                                  QUOTE: quote)
                          || decoded_index := size(input<-bb)
                      END
                  END
              ELSE error_occurred := TRUE
              END
           END   
        END;
   tt <-- error_status = tt := error_occurred;
   tt <-- ready = tt := bool(written_index < size(output));
   aa <-- read_atom = 
       PRE written_index < size(output)
       THEN
           aa := output(written_index + 1)
           || written_index := written_index + 1
       END
END