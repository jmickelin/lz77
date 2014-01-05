/* Compressor
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-12-02
 */
MACHINE Compressor
SEES Strings, DecompConstants
    
VARIABLES comp_input,
          comp_output,
          comp_written_index,
          comp_ready_index,
          comp_is_finishing

INVARIANT comp_input:            BYTE_STRINGS &
          comp_output:           ABSTRACT_STRINGS &
          comp_written_index:    NATURAL &
          comp_ready_index:      NATURAL &
          comp_is_finishing:     BOOL &
          
          (decomp(comp_output))'RESULT = comp_input &
          (decomp(comp_output))'ERROR  = FALSE &
          comp_written_index <= size(comp_output) &
          (comp_written_index <= comp_ready_index) &
          (comp_ready_index <= size(comp_output)) &
          (comp_is_finishing = TRUE => (comp_ready_index = size(comp_output)))
          
INITIALISATION comp_input := <> 
               || comp_output := <>
               || comp_written_index := 0
               || comp_ready_index := 0
               || comp_is_finishing := FALSE
OPERATIONS
    /* To find valid transitions, ProB requires a long timeout. */
    /* debug <-- */ /* Output the chosen suffix for animation */
    comp_put_byte(bb) = 
       PRE bb:BYTE &
           comp_is_finishing = FALSE
       THEN
           comp_input := comp_input <- bb
           || ANY as,nn WHERE as: ABSTRACT_STRINGS &
                              nn: NAT &
                              (decomp((comp_output/|\ comp_written_index) ^ as))'RESULT = comp_input <- bb &
                              (decomp((comp_output/|\ comp_written_index) ^ as))'ERROR = FALSE &
                              (nn <= size(as) - (comp_ready_index - comp_written_index))
                              /* & size(as) < 3 */ /* Limit search space for animation */
              THEN comp_output := (comp_output/|\ comp_written_index) ^ as
                  || comp_ready_index := comp_ready_index + nn
                  /* || debug := as */
              END
       END;
    /* debug <-- */ /* Output the chosen suffix for animation */
    comp_finish = 
          PRE comp_is_finishing = FALSE
             THEN
                ANY as WHERE as: ABSTRACT_STRINGS &
                             (decomp((comp_output /|\ comp_written_index) ^ as))'RESULT = comp_input &
                             (decomp((comp_output /|\ comp_written_index) ^ as))'ERROR = FALSE 
                             /* & size(as) < 3 */ /* Limit search space for animation */
                THEN comp_output := (comp_output /|\ comp_written_index) ^ as
                    || comp_ready_index := size((comp_output /|\ comp_written_index) ^ as)
                    || comp_is_finishing := TRUE
                    /* || debug := as */
                END
          END;
    tt <-- comp_finishing = tt := comp_is_finishing;
    tt <-- comp_ready = tt := bool(comp_written_index < comp_ready_index);
    tag,pp,ll,qq <-- comp_read_atom =
       PRE comp_written_index < comp_ready_index
       THEN
           LET aa BE aa = comp_output(comp_written_index + 1)
           IN tag,pp,ll,qq := aa'TAG,aa'POINTER,aa'RUNLENGTH,aa'QUOTE
           END
           || comp_written_index := comp_written_index + 1
       END
END
