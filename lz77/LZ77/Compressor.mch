/* Compressor
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-12-02
 */
MACHINE Compressor
SEES Strings, DecompConstants
    
VARIABLES input,
          output,
          written_index,
          is_ready,
          is_finishing

INVARIANT input:            BYTE_STRINGS &
          output:           ABSTRACT_STRINGS &
          written_index:    NATURAL &
          is_ready:         BOOL &
          is_finishing:     BOOL &
          
          (decomp(output))'RESULT = input &
          (decomp(output))'ERROR  = FALSE &
          written_index <= size(output) &
          (is_ready = TRUE => written_index < size(output)) &
          (is_finishing = TRUE & written_index < size(output) => is_ready = TRUE)
          
INITIALISATION input := <> 
               || output := <>
               || written_index := 0
               || is_ready := FALSE
               || is_finishing := FALSE
OPERATIONS
    /* To find valid transitions, ProB requires a long timeout. */
    /* debug <-- */ /* Output the chosen suffix for animation */
    put_byte(bb) = 
       PRE bb:BYTE &
           is_finishing = FALSE
       THEN
           input := input <- bb
           || ANY as,tt WHERE as: ABSTRACT_STRINGS &
                              tt: BOOL &
                              (decomp((output/|\ written_index) ^ as))'RESULT = input <- bb &
                              (decomp((output/|\ written_index) ^ as))'ERROR = FALSE &
                              (tt = TRUE => 0 < size(as))
                              /* & size(as) < 3 */ /* Limit search space for animation */
              THEN output := (output/|\ written_index) ^ as
                  || is_ready := tt
                  /* || debug := as */
              END
       END;
    /* debug <-- */ /* Output the chosen suffix for animation */
    finish = PRE is_finishing = FAlSE
             THEN
                 ANY as,tt WHERE as: ABSTRACT_STRINGS &
                                tt: BOOL &
                                (decomp((output /|\ written_index) ^ as))'RESULT = input &
                                (decomp((output /|\ written_index) ^ as))'ERROR = FALSE &
                                ((0 < size(as)) <=> (tt = TRUE))
                                /* & size(as) < 3 */ /* Limit search space for animation */
                THEN output := (output /|\ written_index) ^ as
                    || is_ready := tt
                    || is_finishing := TRUE
                    /* || debug := as */
                END
             END;
    tt <-- finishing = tt := is_finishing;
    tt <-- ready = tt := is_ready;
    tag,pp,ll,qq <-- read_atom =
       PRE is_ready = TRUE
       THEN
           LET aa BE aa = output(written_index + 1)
           IN tag,pp,ll,qq := aa'TAG,aa'POINTER,aa'LENGTH,aa'QUOTE
           END
           || written_index := written_index + 1
           || ANY tt WHERE tt: BOOL &
                           (tt = TRUE => written_index + 1 < size(output)) &
                           (is_finishing = TRUE & written_index + 1 < size(output) => tt = TRUE)
              THEN 
                 is_ready := tt
              END
       END
END
