is_attachment_col <- function(col) {
  all(
    map_lgl(col, function(z) {
      is.null(z) ||
        (is.list(z) && !is.null(z$filename))
    })
  )
}


# Save attachments for a single cell, only if not already in directory
get_airtable_attachments <- function(attachments, attachments_dir) {
  for (i in seq_len(nrow(attachments))) {
    slug <- stringi::stri_extract_first_regex(attachments$url[i], "(?<=\\.attachments\\/).*$")
    download_dest <- file.path(attachments_dir, slug)
    if (!file.exists(download_dest) || file.info(download_dest)$size != attachments$size[i]) {
      if (!dir.exists(dirname(download_dest))) dir.create(dirname(download_dest), recursive = TRUE)
      download.file(attachments$url[i], destfile = download_dest, quiet = TRUE) # Do this with curl::multi_run?
    }
  }
}

# Collapse complex structures, save attachments if the directory is not NULL
write_airtable_to_csv <- function(df, filename, attachments_dir = NULL, ...) {
  # Convert any columns of attachments to comma-delimited URLs
  df <- mutate_if(df, is_attachment_col, function(x) {
    map_chr(x, function(z) {
      if (is.null(z)) {
        return(NA_character_)
      } else {
        if (!is.null(attachments_dir)) {
          get_airtable_attachments(z, attachments_dir)
        }
        return(paste(paste0(z$filename, " (", z$url, ")"), collapse = ","))
      }
    })
  })

  # Convert other multi-entries into comma-delimited strings
  df <- mutate_if(df, is.list, function(x) {
    map_chr(x, function(z) paste(sort(z), collapse = ","))
  })
  write_csv(df, filename, ...)
}

save_airtable <- function(base, tables, path = ".", attachments_dir = NULL) {
  base_obj <- airtable(base, tables)
  imap_chr(base_obj, function(tab, tabname) {
    df <- tab$select_all()
    outfile <- file.path(path, paste0(tabname, ".csv"))
    write_airtable_to_csv(df, outfile, attachments_dir = attachments_dir)
    return(outfile)
  })
}

