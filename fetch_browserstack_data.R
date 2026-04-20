# fetch_browserstack_data.R
# Fetches all test cases from BrowserStack Test Management API,
# writes browserstack_test_cases.csv, and uploads to Google Sheets.
#
# Env:
#   BROWSERSTACK_API_KEY — user:key
#   AUTOMATION_SHEET_ID — target spreadsheet
#   GOOGLE_SA_JSON_PATH or GOOGLE_SA_JSON — service account (same as dashboards)
#
# Writes need Editor on the spreadsheet. Dashboards only read Sheets; if reads work
# but upload returns 403, share the file with the service account as Editor (not Viewer).

library(httr)
library(jsonlite)
library(googlesheets4)

BROWSERSTACK_TEST_CASES_TAB <- "Browserstack Test Cases"

`%||%` <- function(x, y) if (is.null(x)) y else x

resolve_sa_json_path <- function() {
  p <- Sys.getenv("GOOGLE_SA_JSON_PATH", unset = "")
  if (!nzchar(p)) return("")
  if (file.exists(p)) return(normalizePath(p, winslash = "/", mustWork = TRUE))
  p2 <- file.path(getwd(), p)
  if (file.exists(p2)) return(normalizePath(p2, winslash = "/", mustWork = TRUE))
  p
}

service_account_client_email <- function() {
  json_inline <- Sys.getenv("GOOGLE_SA_JSON", unset = "")
  json_path <- resolve_sa_json_path()
  x <- tryCatch(
    if (nzchar(json_inline)) {
      jsonlite::fromJSON(json_inline, simplifyVector = TRUE)
    } else if (nzchar(json_path) && file.exists(json_path)) {
      jsonlite::fromJSON(json_path, simplifyVector = TRUE)
    } else {
      NULL
    },
    error = function(e) NULL
  )
  if (is.null(x) || is.null(x$client_email)) NA_character_ else as.character(x$client_email)
}

# Same credential order as shortcut-bugs-dashboard-static.Rmd auth_gs(), but:
# - gs4_deauth() drops any cached user OAuth token so writes use the service account
# - email = NA, cache = FALSE avoids reusing a read-only cached OAuth token for writes
gs4_auth_from_env <- function() {
  json_inline <- Sys.getenv("GOOGLE_SA_JSON", unset = "")
  json_path <- resolve_sa_json_path()
  if (!nzchar(json_inline) && (!nzchar(json_path) || !file.exists(json_path))) {
    stop(
      "Set GOOGLE_SA_JSON (e.g. Posit Connect) or GOOGLE_SA_JSON_PATH (local file) with valid credentials",
      call. = FALSE
    )
  }
  gs4_deauth()
  if (nzchar(json_inline)) {
    gs4_auth(path = json_inline, email = NA, cache = FALSE)
  } else {
    gs4_auth(path = json_path, email = NA, cache = FALSE)
  }
}

upload_browserstack_sheet <- function(df, ss_id, sheet = BROWSERSTACK_TEST_CASES_TAB) {
  gs4_auth_from_env()
  sheet_write(df, ss = ss_id, sheet = sheet)
  message(sprintf(
    "Uploaded %d rows to tab \"%s\" (%s)",
    nrow(df), sheet, ss_id
  ))
}

sheets_upload_error_hint <- function(err) {
  msg <- conditionMessage(err)
  em <- service_account_client_email()
  if (grepl("403|PERMISSION_DENIED", msg, ignore.case = TRUE)) {
    hint <- paste0(
      "Spreadsheet writes require Editor access for the active Google identity. ",
      "Dashboards only call read_sheet(), which can work with Viewer. ",
      "In Google Sheets: Share → add the service account email as Editor."
    )
    if (!is.na(em) && nzchar(em)) {
      hint <- paste0(hint, " Service account: ", em)
    }
    paste0(msg, "\n", hint)
  } else {
    msg
  }
}

fetch_browserstack_test_cases <- function(upload_to_sheet = TRUE) {
  api_key <- Sys.getenv("BROWSERSTACK_API_KEY", unset = "")
  if (!nzchar(api_key)) {
    message("BROWSERSTACK_API_KEY not set – using cached CSV if available.")
    return(NULL)
  }

  # One handle + cached basic auth → connection reuse across many small GETs
  ht_user <- sub(":.*", "", api_key)
  ht_pwd <- sub(".*:", "", api_key)
  host_handle <- handle("https://test-management.browserstack.com")
  api_prefix <- "/api/v2/projects/PR-4"

  http_get <- function(path) {
    GET(handle = host_handle, path = path, config = authenticate(ht_user, ht_pwd))
  }

  # --- Fetch folders ---
  fetch_all_folders <- function() {
    folder_map <- list()

    fetch_sub <- function(parent_id = NULL) {
      path <- if (is.null(parent_id)) {
        paste0(api_prefix, "/folders")
      } else {
        paste0(api_prefix, "/folders/", parent_id, "/sub-folders")
      }
      resp <- http_get(path)
      if (status_code(resp) != 200) return()
      folders <- content(resp, as = "parsed")$folders
      for (f in folders) {
        folder_map[[as.character(f$id)]] <<- list(
          id   = f$id,
          name = f$name,
          parent_id = parent_id
        )
        fetch_sub(f$id)
      }
    }

    fetch_sub()
    folder_map
  }

  message("Fetching BrowserStack folders...")
  folder_map <- fetch_all_folders()
  message(sprintf("  Found %d folders", length(folder_map)))

  get_folder_name <- function(fid) {
    fid_c <- as.character(fid)
    if (fid_c %in% names(folder_map)) folder_map[[fid_c]]$name else paste0("Unknown-", fid)
  }

  # --- Fetch test cases (paginated) ---
  # Grow a list of pages then unlist once (avoids O(n²) copies from c(all, page))
  page_chunks <- list()
  page <- 1
  repeat {
    resp <- http_get(paste0(api_prefix, "/test-cases?p=", page))
    if (status_code(resp) != 200) break
    body <- content(resp, as = "parsed")
    cases <- body$test_cases %||% list()
    page_chunks[[length(page_chunks) + 1L]] <- cases
    message(sprintf("  Page %d: %d cases (total %d)", page, length(cases), sum(lengths(page_chunks))))
    nxt <- body$info$`next`
    if (is.null(nxt)) break
    page <- nxt
  }
  all_cases <- unlist(page_chunks, recursive = FALSE)
  message(sprintf("Total test cases: %d", length(all_cases)))

  # --- Build data frame ---
  normalize_priority <- function(p) {
    p <- trimws(p)
    if (tolower(p) %in% c("medium", "meidum", "edium", "medum")) return("Medium")
    if (p %in% c("Critical", "High", "Low")) return(p)
    return("Medium")
  }

  if (!length(all_cases)) {
    df <- data.frame(
      identifier = character(),
      title = character(),
      top_level_folder = character(),
      second_level_folder = character(),
      full_path = character(),
      folder_id = character(),
      automation_status = character(),
      priority = character(),
      status = character(),
      case_type = character(),
      owner = character(),
      created_at = character(),
      last_updated_at = character(),
      stringsAsFactors = FALSE
    )
  } else {
    fp_list <- lapply(all_cases, function(tc) unlist(tc$folder_path))
    n <- length(all_cases)
    top <- character(n)
    second <- character(n)
    full <- character(n)
    for (i in seq_len(n)) {
      fp <- fp_list[[i]]
      top[i] <- if (length(fp) >= 1L) get_folder_name(fp[1L]) else "Unknown"
      second[i] <- if (length(fp) >= 2L) get_folder_name(fp[2L]) else "(root)"
      full[i] <- paste(vapply(fp, get_folder_name, ""), collapse = " / ")
    }

    df <- data.frame(
      identifier = vapply(all_cases, function(tc) as.character(tc$identifier %||% ""), ""),
      title = vapply(all_cases, function(tc) as.character(tc$title %||% ""), ""),
      top_level_folder = top,
      second_level_folder = second,
      full_path = full,
      folder_id = vapply(all_cases, function(tc) as.character(tc$folder_id %||% ""), ""),
      automation_status = vapply(all_cases, function(tc) as.character(tc$automation_status %||% "not_automated"), ""),
      priority = vapply(all_cases, function(tc) normalize_priority(tc$priority %||% "Medium"), ""),
      status = vapply(all_cases, function(tc) as.character(tc$status %||% "Active"), ""),
      case_type = vapply(all_cases, function(tc) as.character(tc$case_type %||% ""), ""),
      owner = vapply(all_cases, function(tc) as.character(tc$owner %||% ""), ""),
      created_at = vapply(all_cases, function(tc) as.character(tc$created_at %||% ""), ""),
      last_updated_at = vapply(all_cases, function(tc) as.character(tc$last_updated_at %||% ""), ""),
      stringsAsFactors = FALSE
    )
  }

  out_path <- file.path(getwd(), "browserstack_test_cases.csv")
  write.csv(df, out_path, row.names = FALSE)
  message(sprintf("Wrote %d rows to %s", nrow(df), out_path))

  if (isTRUE(upload_to_sheet)) {
    ss_id <- Sys.getenv("AUTOMATION_SHEET_ID", unset = "")
    json_inline <- Sys.getenv("GOOGLE_SA_JSON", unset = "")
    json_path <- resolve_sa_json_path()
    has_auth <- nzchar(json_inline) || (nzchar(json_path) && file.exists(json_path))
    if (!nzchar(ss_id)) {
      message("AUTOMATION_SHEET_ID not set — skipping Google Sheets upload.")
    } else if (!has_auth) {
      message("Google service account env not set or file missing — skipping Google Sheets upload.")
    } else {
      tryCatch(
        upload_browserstack_sheet(df, ss_id),
        error = function(e) {
          warning("Google Sheets upload failed: ", sheets_upload_error_hint(e), call. = FALSE)
        }
      )
    }
  }

  df
}

# Run if executed directly
if (sys.nframe() == 0) {
  t_start <- proc.time()
  fetch_browserstack_test_cases()
  elapsed <- proc.time() - t_start
  message(sprintf("Elapsed: %.2f s", elapsed["elapsed"]))
}
