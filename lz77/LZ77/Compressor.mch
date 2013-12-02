/* Compressor
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-12-02
 */
MACHINE Compressor
SEES Strings, DecompConstants
    
VARIABLES retrieved_input, /* The input string whose corresponding compressed string has been retrieved from the machine */
          noncompressed_input_buffer,  /* The input that is waiting to be processed */
          compressed_input_buffer,    /* The input that is processed but whose corresponding compressed string has not been retrieved */
          /* All input is retrieved_compressed_input ^ compressed_input_buffer ^ uncompressed_input_buffer */
          written,                    /* The compressed data that has been retrieved from the machine */
          output_buffer               /* The compressed data waiting to be retrieved from the machine */

INVARIANT retrieved_input:            BYTE_STRINGS &
          noncompressed_input_buffer: BYTE_STRINGS &
          compressed_input_buffer:    BYTE_STRINGS &
          written:                ABSTRACT_STRINGS &
          output_buffer:          ABSTRACT_STRINGS &
          
          (decomp(written ^ output_buffer))'RESULT = retrieved_input ^ compressed_input_buffer &
          (decomp(written ^ output_buffer))'ERROR  = FALSE &
          (decomp(written))'RESULT = retrieved_input &
          (decomp(written))'ERROR  = FALSE
          
INITIALISATION retrieved_input := <> 
               || noncompressed_input_buffer := <>
               || compressed_input_buffer := <>
               || written := <>
               || output_buffer := <>
OPERATIONS
    put_byte(bb) = 
       PRE bb:BYTE
       THEN
           CHOICE noncompressed_input_buffer := noncompressed_input_buffer <- bb
           OR ANY s1,s2,aa 
              WHERE s1: BYTE_STRINGS & s2: BYTE_STRINGS & aa: ATOMS &
                    s1 ^ s2 = noncompressed_input_buffer <- bb &
                    (decomp(written ^ output_buffer <- aa))'RESULT = 
                            retrieved_input ^ compressed_input_buffer ^ s1 &
                    (decomp(written ^ output_buffer <- aa))'ERROR  = FALSE
              THEN noncompressed_input_buffer := s2
                  || compressed_input_buffer := compressed_input_buffer ^ s1
                  || output_buffer := output_buffer <- aa
              END
           END
       END;
    tt <-- ready = tt := bool(output_buffer /= <>);
    aa <-- read_atom =
       PRE output_buffer /= <>
       THEN 
           ANY s1,s2
           WHERE s1: BYTE_STRINGS & s2: BYTE_STRINGS &
                 s1 ^ s2 = compressed_input_buffer &
                 (decomp_atom(first(output_buffer), retrieved_input))'RESULT = s1 &
                 (decomp_atom(first(output_buffer), retrieved_input))'ERROR  = FALSE
           THEN
             aa := first(output_buffer)
             || output_buffer := tail(output_buffer)
             || written := written <- first(output_buffer)
             || retrieved_input := retrieved_input ^ s1
             || compressed_input_buffer := s2
           END
       END
END
