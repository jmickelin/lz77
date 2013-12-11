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
           LET nondecoded BE
               nondecoded = (input<-bb)\|/decoded_index
           IN
              SELECT nondecoded(1) = ref_code THEN
                  IF size(nondecoded) = 1 + pointer_nbytes + runlength_nbytes
                  THEN
                      LET pointer,length BE
                          pointer = (nondecoded \|/ 1) /|\ pointer_nbytes &
                          length  = (nondecoded \|/ (1 + pointer_nbytes)) /|\ runlength_nbytes
                      IN
                          output := output <- rec(TAG:Ref,
                                                  POINTER: decode_pointer(pointer),
                                                  RUNLENGTH: decode_runlength(length),
                                                  QUOTE: <>)
                          || decoded_index := size(input<-bb)
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
                              output := output <- rec(TAG:Lit,
                                                      POINTER: 0,
                                                      RUNLENGTH: 0,
                                                      QUOTE: partial_quote) /* Exactly the whole quote */
                              || decoded_index := size(input<-bb)
                          END
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