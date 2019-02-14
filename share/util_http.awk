
function urldecode(text,   hex, i, hextab, decoded, len, c, c1, c2, code) {
# decode urlencoded string
# urldecode function from Heiner Steven
#   http://www.shelldorado.com/scripts/cmds/urldecode
	
  split("0 1 2 3 4 5 6 7 8 9 a b c d e f", hex, " ")
  for (i=0; i<16; i++) hextab[hex[i+1]] = i
  
  decoded = ""
  i = 1
  len = length(text)
  
  while ( i <= len ) {
    c = substr (text, i, 1)
    if ( c == "%" ) {
      if ( i+2 <= len ) {
        c1 = tolower(substr(text, i+1, 1))
        c2 = tolower(substr(text, i+2, 1))
        if ( hextab [c1] != "" || hextab [c2] != "" ) {
          # print "Read: %" c1 c2;
          # Allow: 
          # 20 begins main chars, but dissallow 7F (wrong in orig code!)
          #   tab, newline, formfeed, carriage return
          if ( ( (c1 >= 2) && ((c1 c2) != "7f") )   \
               || (c1 == 0 && c2 ~ "[9acd]") )
            {
              code = 0 + hextab [c1] * 16 + hextab [c2] + 0
              # print "Code: " code
              c = sprintf ("%c", code)
            } else {
            # for dissallowed chars
            c = " "
          }
          i = i + 2
        }
      }
    } else if ( c == "+" ) {	# special handling: "+" means " "
      c = " "
    }
    decoded = decoded c
    ++i
  }
  
  # change linebreaks to \n
  gsub(/\r\n/, "\n", decoded);
  
  # remove last linebreak
  sub(/[\n\r]*$/,"",decoded);
  
  return decoded
}

function urlencode(text    , hextab, i, ord, encoded, c, lo, hi) {
  # http://www.shelldorado.com/scripts/cmds/urlencode.txt
  split ("1 2 3 4 5 6 7 8 9 A B C D E F", hextab, " ")
  hextab [0] = 0
  for ( i=1; i<=255; ++i ) ord [ sprintf ("%c", i) "" ] = i + 0
  encoded = ""
  for ( i=1; i<=length (text); ++i ) {
    c = substr (text, i, 1)
    if ( c ~ /[a-zA-Z0-9.-]/ ) {
      encoded = encoded c		# safe character
    } else if ( c == " " ) {
      encoded = encoded "+"	# special handling
    } else {
      # unsafe character, encode it as a two-digit hex-number
      lo = ord [c] % 16
      hi = int (ord [c] / 16);
      encoded = encoded "%" hextab [hi] hextab [lo]
    }
  }
  return encoded ;
}

