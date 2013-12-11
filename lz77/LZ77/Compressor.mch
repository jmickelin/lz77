/* Compressor
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-12-02
 */
MACHINE Compressor
SEES Strings, DecompConstants
    
VARIABLES comp_input,
          comp_output,
          comp_written_index,
          comp_is_ready,
          comp_is_finishing

INVARIANT comp_input:            BYTE_STRINGS &
          comp_output:           ABSTRACT_STRINGS &
          comp_written_index:    NATURAL &
          comp_is_ready:         BOOL &
          comp_is_finishing:     BOOL &
          
          (decomp(comp_output))'RESULT = comp_input &
          (decomp(comp_output))'ERROR  = FALSE &
          comp_written_index <= size(comp_output) &
          (comp_is_ready = TRUE => comp_written_index < size(comp_output)) &
          (comp_is_finishing = TRUE & comp_written_index < size(comp_output) 
              => comp_is_ready = TRUE)
          
INITIALISATION comp_input := <> 
               || comp_output := <>
               || comp_written_index := 0
               || comp_is_ready := FALSE
               || comp_is_finishing := FALSE
OPERATIONS
    /* To find valid transitions, ProB requires a long timeout. */
    /* debug <-- */ /* Output the chosen suffix for animation */
    comp_put_byte(bb) = 
       PRE bb:BYTE &
           comp_is_finishing = FALSE
       THEN
           comp_input := comp_input <- bb
           || ANY as,tt WHERE as: ABSTRACT_STRINGS &
                              tt: BOOL &
                              (decomp((comp_output/|\ comp_written_index) ^ as))'RESULT = comp_input <- bb &
                              (decomp((comp_output/|\ comp_written_index) ^ as))'ERROR = FALSE &
                              (tt = TRUE => 0 < size(as))
                              /* & size(as) < 3 */ /* Limit search space for animation */
              THEN comp_output := (comp_output/|\ comp_written_index) ^ as
                  || comp_is_ready := tt
                  /* || debug := as */
              END
       END;
    /* debug <-- */ /* Output the chosen suffix for animation */
    comp_finish = 
          PRE comp_is_finishing = FALSE
             THEN
                 ANY as,tt WHERE as: ABSTRACT_STRINGS &
                                tt: BOOL &
                                (decomp((comp_output /|\ comp_written_index) ^ as))'RESULT = comp_input &
                                (decomp((comp_output /|\ comp_written_index) ^ as))'ERROR = FALSE &
                                ((0 < size(as)) <=> (tt = TRUE))
                                /* & size(as) < 3 */ /* Limit search space for animation */
                THEN comp_output := (comp_output /|\ comp_written_index) ^ as
                    || comp_is_ready := tt
                    || comp_is_finishing := TRUE
                    /* || debug := as */
                END
          END;
    tt <-- comp_finishing = tt := comp_is_finishing;
    tt <-- comp_ready = tt := comp_is_ready;
    tag,pp,ll,qq <-- comp_read_atom =
       PRE comp_is_ready = TRUE
       THEN
           LET aa BE aa = comp_output(comp_written_index + 1)
           IN tag,pp,ll,qq := aa'TAG,aa'POINTER,aa'RUNLENGTH,aa'QUOTE
           END
           || comp_written_index := comp_written_index + 1
           || ANY tt WHERE tt: BOOL &
                           (tt = TRUE => comp_written_index + 1 < size(comp_output)) &
                           (comp_is_finishing = TRUE & comp_written_index + 1 < size(comp_output) => tt = TRUE)
              THEN 
                 comp_is_ready := tt
              END
       END
END
