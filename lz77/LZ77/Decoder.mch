/* Decoder
 * Author: 
 * Creation date: 2013-12-08
 */
MACHINE Decoder
SEES Strings, EncodeConstants
VARIABLES dec_input,
          dec_output,
          dec_decoded_index,
          dec_written_index,
          dec_error_occurred
INVARIANT dec_input: BYTE_STRINGS &
          dec_output: ABSTRACT_STRINGS &
          dec_decoded_index: NATURAL &
          dec_written_index: NATURAL &
          dec_error_occurred: BOOL &
          
          dec_written_index <= size(dec_output) &
          dec_decoded_index <= size(dec_input)
          
INITIALISATION dec_input := <>
               || dec_output := <>
               || dec_decoded_index := 0
               || dec_written_index := 0
               || dec_error_occurred := FALSE
OPERATIONS
    dec_put_byte(bb) = 
        PRE bb: BYTE
        THEN
           dec_input := dec_input<- bb
           ||
           LET nondecoded BE
               nondecoded = (dec_input<-bb)\|/dec_decoded_index
           IN
              SELECT nondecoded(1) = ref_code THEN
                  IF size(nondecoded) = 1 + pointer_nbytes + runlength_nbytes
                  THEN
                      LET pointer,length BE
                          pointer = (nondecoded \|/ 1) /|\ pointer_nbytes &
                          length  = (nondecoded \|/ (1 + pointer_nbytes)) /|\ runlength_nbytes
                      IN
                          dec_output := dec_output <- rec(TAG:Ref,
                                                          POINTER: decode_pointer(pointer),
                                                          RUNLENGTH: decode_runlength(length),
                                                          QUOTE: <>)
                          || dec_decoded_index := size(dec_input<-bb)
                      END
                  END
              WHEN nondecoded(1) = lit_code THEN
                  IF size(nondecoded) > 1 + quote_length_nbytes THEN
                      LET quote_length, partial_quote
                      BE quote_length = decode_quote_length((nondecoded \|/ 1) /|\ quote_length_nbytes) &
                         partial_quote = (nondecoded \|/ (1 + quote_length_nbytes))
                      IN
                          IF size(nondecoded) = 1 + quote_length_nbytes + quote_length
                          THEN
                              dec_output := dec_output <- rec(TAG:Lit,
                                                              POINTER: 0,
                                                              RUNLENGTH: 0,
                                                              QUOTE: partial_quote) /* Exactly the whole quote */
                              || dec_decoded_index := size(dec_input<-bb)
                          END
                      END
                  END
              ELSE dec_error_occurred := TRUE
              END
           END
        END;
   tt <-- dec_error_status = tt := dec_error_occurred;
   tt <-- dec_ready = tt := bool(dec_written_index < size(dec_output));
   aa <-- dec_read_atom = 
       PRE dec_written_index < size(dec_output)
       THEN
           aa := dec_output(dec_written_index + 1)
           || dec_written_index := dec_written_index + 1
       END
END