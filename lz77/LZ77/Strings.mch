/* Strings
 * Author: Jonne Mickelin, Alvar Bjerkeng van Keppel
 * Creation date: 2013-11-26
 */
MACHINE Strings
SETS TAGS = {Ref, Lit}
CONSTANTS max_pointer,
          max_runlength,
          max_quote_length

ABSTRACT_CONSTANTS REFERENCES, 
          LITERALS, 
          ATOMS,
          BYTE_STRINGS,
          ABSTRACT_STRINGS,
          MAYBE_STRINGS,
          ATOM_UNIVERSE,
          QUOTES
PROPERTIES max_pointer: NAT1 &
           max_runlength: NAT1 &
           max_quote_length: NAT1 &
           /* max_pointer = 2 & 
              max_runlength = 2 & 
              max_quote_length = 2 & */ /* Give explicit values, for animation. */
           BYTE_STRINGS = seq(0..255) &
           QUOTES = 0..max_quote_length --> 0..255 & // We ignore the first byte, so this is an array of max_quote_length bytes.
           ATOM_UNIVERSE = struct(TAG:TAGS, 
                                  POINTER:NAT,
                                  RUNLENGTH:NAT,
                                  QUOTE_LEN:0..max_quote_length,
                                  QUOTE: QUOTES) &
           REFERENCES = { aa | aa:ATOM_UNIVERSE &
                               aa'TAG = Ref &
                               aa'POINTER: (1..max_pointer) & 
                               aa'RUNLENGTH: (1..max_runlength) &
                               aa'QUOTE_LEN = 0 &
                               aa'QUOTE = (0..max_quote_length) * {0}
                        } &
           LITERALS = { aa | aa:ATOM_UNIVERSE &
                             aa'TAG = Lit &
                             aa'POINTER = 0 & 
                             aa'RUNLENGTH = 0 &
                             aa'QUOTE_LEN > 0
                      } &
           ATOMS = REFERENCES \/ LITERALS &
           ABSTRACT_STRINGS = seq(ATOMS) &
           MAYBE_STRINGS = struct(RESULT:BYTE_STRINGS, ERROR:BOOL)
END