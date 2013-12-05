/* Compressor
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-12-02
 */
MACHINE Compressor
SEES Strings, DecompConstants
    
VARIABLES input,
          output,
          written_index,
          is_ready

INVARIANT input:            BYTE_STRINGS &
          output:           ABSTRACT_STRINGS &
          written_index:    NATURAL &
          is_ready:         BOOL &
          
          (decomp(output))'RESULT = input &
          (decomp(output))'ERROR  = FALSE &
          written_index <= size(output) &
          (is_ready = TRUE => written_index < size(output))
          
INITIALISATION input := <> 
               || output := <>
               || written_index := 0
               || is_ready := FALSE
OPERATIONS
    put_byte(bb) = 
       PRE bb:BYTE
       THEN
           input := input <- bb
           || ANY as,tt WHERE as: ABSTRACT_STRINGS &
                              tt: BOOL &
                              (decomp(as))'RESULT = input <- bb &
                              (decomp(as))'ERROR = FALSE &
                              written_index <= size(as) & /* This is implied by the next line */
                              as /|\ written_index = output /|\ written_index &
                              (tt = TRUE => written_index < size(as))
              THEN output := as
                  || is_ready := tt
              END
       END;
    tt <-- ready = tt := is_ready;
    tag,pp,ll,qq <-- read_atom =
       PRE is_ready = TRUE
       THEN
           LET aa BE aa = output(written_index + 1)
           IN tag,pp,ll,qq := aa'TAG,aa'POINTER,aa'LENGTH,aa'QUOTE
           END
           || written_index := written_index + 1
           || ANY tt WHERE tt: BOOL &
                           (tt = TRUE => written_index + 1 < size(output))
              THEN 
                 is_ready := tt
              END
       END
END
