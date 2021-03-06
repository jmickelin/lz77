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
          dec_error_occurred,
          dec_is_finishing
          
INVARIANT dec_input: BYTE_STRINGS &
          dec_output: ABSTRACT_STRINGS &
          dec_decoded_index: NATURAL &
          dec_written_index: NATURAL &
          dec_error_occurred: BOOL &
          dec_is_finishing: BOOL &
          
          dec_written_index <= size(dec_output) &
          dec_decoded_index <= size(dec_input)
          
INITIALISATION dec_input := <>
               || dec_output := <>
               || dec_decoded_index := 0
               || dec_written_index := 0
               || dec_error_occurred := FALSE
               || dec_is_finishing := FALSE
               
OPERATIONS
    dec_put_byte(bb) = 
        PRE bb: 0..255 &
            dec_is_finishing = FALSE &
            dec_error_occurred = FALSE &
            size(dec_output) - dec_written_index = 0
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
                                                          QUOTE_LEN: 0,
                                                          QUOTE: (0..max_quote_length)*{0})
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
                              // The partial_quote is exactly the whole quote.
                              dec_output := dec_output <- 
                                      rec(TAG:Lit,
                                          POINTER: 0,
                                          RUNLENGTH: 0,
                                          QUOTE_LEN: quote_length,
                                          QUOTE: ((partial_quote ^ (1..(max_quote_length - quote_length))*{0})<+{0|->0}))
                              || dec_decoded_index := size(dec_input<-bb)
                          END
                      END
                  END
              ELSE dec_error_occurred := TRUE
              END
           END
        END;
   tt <-- dec_error_status = tt := dec_error_occurred;
   dec_finish = PRE dec_is_finishing = FALSE
                THEN
                    dec_error_occurred := bool(dec_decoded_index < size(dec_input))
                    || dec_is_finishing := TRUE
                END;
   tt <-- dec_finishing = tt := dec_is_finishing;
   tt <-- dec_ready = tt := bool(dec_written_index < size(dec_output));
   tag,pp,ll,qqlen,qq <-- dec_read_atom = 
       PRE dec_written_index < size(dec_output)
       THEN
           LET aa BE aa = dec_output(dec_written_index + 1)
           IN tag,pp,ll,qqlen,qq := aa'TAG,aa'POINTER,aa'RUNLENGTH,aa'QUOTE_LEN,aa'QUOTE
           END
           || dec_written_index := dec_written_index + 1
       END
END