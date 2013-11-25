MACHINE Compressor(..., ...)
SEES String(..., ...)

CONSTANTS isconcat, decomp, decomp_atom
PROPERTIES isconcat <: seq(BYTE_STRINGS)*BYTE_STRINGS &
           isconcat = { s,a | s: seq(BYTE_STRINGS) & a: BYTE_STRINGS &
                              (SIGMA i . (i : dom(s) | size(s(i)))) = size(a) & 
                              ! i . (i : dom(s) => s(i) = (a \|/ (SIGMA j . (j < i | size(s(j))))) /|\ size(s(i)))
                      }
           decomp_atom: ATOMS <-> BYTE_STRINGS &
           decomp_atom = { aa,bs | aa: ATOMS & bs: BYTE_STRINGS &
                                   # litstr . (litstr: BYTE_STRINGS &
                                               (aa = (lit, litstr) => bs = litstr)) &
                                   # pp,ll . (pp:NAT & ll:NAT &
                                              (aa = (ref, pp, ll) & pp < size(bs) 
                                                     => bs = %nn . (nn:0..(ll-1) | bs(size(bs) - pp + (nn mod pp)))))
                         }
           decomp: ABSTRACT_STRINGS <-> BYTE_STRINGS &
           decomp = { as,bs | as:ABSTRACT_STRING & bs: BYTE_STRINGS &
                              (as = <> => bs = <>) &
                              (size(as) > 0 & front(as): dom(decomp) => # bs1 . (front(as) |-> bs1: decomp & 
                                                                                 bs1 ^ decomp_atom(last(as)) = bs))
                    }
THEOREMS
        decomp_atom: ATOMS +-> BYTE_STRINGS &
        decomp: ABSTRACT_STRINGS +-> BYTE_STRINGS
VARIABLES retrieved_compressed_input, /* The input string whose corresponding compressed string has been retrieved from the machine */
          uncompressed_input_buffer,  /* The input that is waiting to be processed */
          compressed_input_buffer,    /* The input that is processed but whose corresponding compressed string has not been retrieved */
          /* All input is retrieved_compressed_input ^ compressed_input_buffer ^ uncompressed_input_buffer */
          written,                    /* The compressed data that has been retrieved from the machine */
          output_buffer               /* The compressed data waiting to be retrieved from the machine */

INVARIANT compressed_written_input:     BYTE_STRINGS &
          input_buffer:                 BYTE_STRINGS &
          compressed_input_buffer:      BYTE_STRINGS &
          written:                  ABSTRACT_STRINGS &
          output_buffer:            ABSTRACT_STRINGS &

          /* isdecomp(retrieved_compressed_input, written) */
OPERATIONS
  queue_byte(bb) = 
      PRE bb:BYTE &
          size(input_buffer) <= input_buffer_max_size
      THEN
          input_buffer := input_buffer <- bb
          || output_buffer :=
          || compressed_input_buffer := 
      END
   tt <-- ready =
      PRE
      THEN
      END
   aa <-- read_atom =
      PRE
      THEN
      END