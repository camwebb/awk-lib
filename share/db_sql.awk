

function db_query(db, query            , row, i, cmd, preFS ) {
  gsub(/`/,"\\`", query)  # if writing directly in awk script, need: \\\`
  gsub(/\n/," ", query)
  gsub(/\ \ */," ", query)
  cmd = "/bin/echo -e \"" query "\" | mysql -u " DBUSER[db] " -p" \
    DBPASSWORD[db] " -h " DBHOST[db] \
    " -B --column-names --default-character-set=utf8 " db 
  # print cmd
  row = -1
  preFS = FS
  FS = "\t"
  while ((cmd | getline ) > 0) {
    row++
    if (row == 0) {
      DBQc = NF
      for (i = 1; i <= NF; i++) DBQf[i] = $i
    }
    else {
      for (i = 1; i <= NF; i++) {
        gsub(/NULL/,"",$i)
        DBQ[row, DBQf[i]] = $i
      }
    }
  }
  close(cmd)
  # In the case of Empty Set
  if (row == -1) row = 0
  DBQr = row
  FS = preFS
}


function db_print_table_html(width, links,      html, widthstr, i, j, link, \
                             tmp1, tmp2) 
{
  if (width) widthstr = "width=\"" width "\""
  html = "<table border=\"1\" " widthstr ">"

  # parse links
  split(links, tmp1, "|")
  for (i in tmp1) {
    split(tmp1[i], tmp2, "~")
    link[tmp2[1]] = tmp2[2]
  }
  
  html = html "<tr>"
  for (i = 1; i <= DBQc; i++) html = html "<th>" DBQf[i] "</th>"
  html = html "</tr>"
  for (i = 1; i <= DBQr; i++) {
    html = html "<tr>"
    for (j = 1; j <= DBQc; j++) {
      # empty?
      if (!DBQ[i,DBQf[j]]) DBQ[i,DBQf[j]] = "&#160;"
      # linked?
      else if (link[DBQf[j]])
        DBQ[i,DBQf[j]] = gensub("!", DBQ[i,DBQf[j]], "G", link[DBQf[j]])
      html = html "<td>" DBQ[i,DBQf[j]] "</td>"
    }
    html = html "</tr>"
  }
  html = html "</table>"
  return html
}

function db_clear() {

  delete DBQ
  delete DBQf
  DBQr = 0
  DBQc = 0
}

function db_sql(db, query            , cmd, ES ) {
  gsub(/`/,"\\`",query)  # if writing directly, need: \\\`
  gsub(/\n/," ",query)
  gsub(/\ \ */," ",query)
  cmd = "/bin/echo -e \"" query "\" | mysql -u " DBUSER[db] \
    " -p" DBPASSWORD[db] " -h " DBHOST[db] " " db
  return system(cmd)
  # Test with: gawk 'BEGIN{cmd="echo \x27DELETE from foo WHERE id = 1;\x27 \
  #   | mysql -u cam -ptesttest akchars"; print system(cmd)}'
}
