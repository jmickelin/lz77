/* Strings
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-11-26
 */
MACHINE Strings
SETS TAGS = {Ref, Lit}
CONSTANTS BYTE,
          window_size,
          lookahead_buffer_size,
          max_quote_length

ABSTRACT_CONSTANTS REFERENCES, 
          LITERALS, 
          ATOMS,
          BYTE_STRINGS,
          ABSTRACT_STRINGS,
          MAYBE_STRINGS,
          ATOM_UNIVERSE
PROPERTIES window_size : NAT &
           lookahead_buffer_size : NAT &
           max_quote_length : NAT &
           BYTE = 0..255 &
           BYTE_STRINGS = seq(BYTE) &
           ATOM_UNIVERSE = struct(TAG:TAGS, 
                                  POINTER:NAT, 
                                  LENGTH:NAT, 
                                  QUOTE: 1..max_quote_length --> BYTE) &
           REFERENCES = { aa | aa:ATOM_UNIVERSE &
                               aa'TAG = Ref &
                               aa'POINTER: (1..window_size) & 
                               aa'LENGTH: (1..lookahead_buffer_size) &
                               aa'QUOTE = <>
                        } &
           LITERALS = { aa | aa:ATOM_UNIVERSE &
                             aa'TAG = Lit &
                             aa'POINTER = 0 & 
                             aa'LENGTH = 0 &
                             aa'QUOTE /= <>
                      } &
           ATOMS = REFERENCES \/ LITERALS &
           ABSTRACT_STRINGS = seq(ATOMS) &
           MAYBE_STRINGS = struct(RESULT:BYTE_STRINGS, ERROR:BOOL)
END