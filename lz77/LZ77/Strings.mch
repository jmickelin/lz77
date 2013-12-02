/* Strings
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-11-26
 */
MACHINE Strings
SETS TAGS = {Ref, Lit}
ABSTRACT_CONSTANTS REFERENCES, 
          LITERALS, 
          ATOMS,
          BYTE,
          BYTE_STRINGS, 
          ABSTRACT_STRINGS,
          window_size,
          lookahead_buffer_size,
          MAYBE_STRINGS
PROPERTIES window_size : NAT &
           lookahead_buffer_size : NAT &
           BYTE = 0..255 &
           BYTE_STRINGS = seq(BYTE) &
           REFERENCES = {Ref} * (1..window_size) * (1..lookahead_buffer_size) * { {0 |-> 0} } &
           LITERALS = {Lit} * {0} * {0} * (BYTE_STRINGS - {<>}) &
           ATOMS = REFERENCES \/ LITERALS &
           ABSTRACT_STRINGS = seq(ATOMS) &
           MAYBE_STRINGS = struct(RESULT:BYTE_STRINGS, ERROR:BOOL)
END