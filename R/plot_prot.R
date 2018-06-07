#' Protein structure diagram.
#' 
#' Plots a diagram of protein structure based on hmmscan domain annotation and several types of predictions.
#'
#' @param sequence String representing a protein amino acid sequence.
#' @param id String representing a protein identifier. Will be converted using \code{\link[base]{make.names}} 
#' @param hyp_col Plotting color of predicted hydroxyproline positions. At default set to: '#868686FF'.
#' @param gpi_col Plotting color of the predicted omega site (glycosylphosphatidylinositol attachment). At default set to: '#0073C2FF'.
#' @param nsp_col Plotting color of the N-terminal signal peptide. At default set to: '#CD534CFF'.
#' @param ag_col Plotting color of the AG glycomodul spans. At default set to: '#E5E5E5FF'.
#' @param tm_col Plotting color of the transmembrane regions. At default set to: '#EFC000FF'.
#' @param hyp Bolean, should hydroxyprolines be plotted.
#' @param gpi Bolean, should the omega site be plotted.
#' @param nsp Bolean, should the N-terminal signal peptide be plotted.
#' @param ag Bolean, should the AG glycomodul spans be plotted.
#' @param tm Bolean, should the transmembrane regions be plotted. 
#' @param domain Bolean, should the domains be plotted. 
#' @param dom_sort One of c("ievalue", "abc", "cba"), defaults to "abc". Domain plotting order. If 'ievalue' domains with the lowest ievalue as determined by hmmscan will be plotted above. If 'abc' or 'cba' the order is determined by domain Names.
#' @param ... Appropriate arguments passed to \code{\link[ragp]{get_signalp}}, \code{\link[ragp]{predict_hyp}} and \code{\link[ragp]{scan_ag}}.
#'
#' @return A ggplot2 plot object
#'
#' @seealso \code{\link[ragp]{get_signalp}} \code{\link[ragp]{get_phobius}} \code{\link[ragp]{get_hmm}} \code{\link[ragp]{predict_hyp}} \code{\link[ragp]{scan_ag}}
#'
#' @examples
#' library(ragp)
#' 
#' ind <- c(23,24, 5, 80, 81, 120, 230, 334, 345, 1000)
#' pred <- plot_prot(sequence = at_nsp$sequence[ind],
#'                   id = at_nsp$Transcript.id[ind])
#' 
#' @export

plot_prot <- function(sequence,
                      id,
                      hyp_col = "#868686FF",
                      gpi_col = "#0073C2FF",
                      nsp_col = "#CD534CFF",
                      ag_col = "#E5E5E5FF",
                      tm_col = "#EFC000FF",
                      hyp = TRUE,
                      gpi = TRUE,
                      nsp = TRUE,
                      ag = TRUE,
                      tm = TRUE,
                      domain = TRUE,
                      dom_sort = c("ievalue", "abc", "cba"),
                      ...) {
  
  if (missing(sequence)){
    stop("protein sequence must be provided to obtain predictions")
  }
  if (missing(id)){
    stop("protein id must be provided to obtain predictions")
  }
  id <- as.character(id)
  id <- make.names(id)
  sequence <- toupper(as.character(sequence))
  if (length(sequence) != length(id)){
    stop("id and sequence vectors are not of same length")
  }
  sequence <- sub("\\*$", "", sequence)
  aa_regex <- "[^ARNDCQEGHILKMFPSTWYVarndcqeghilkmfpstwyv]"
  
  if (any(grepl(aa_regex, sequence))){
    warning(paste("sequences: ", paste(id[grepl(aa_regex, sequence)], collapse = ", "), 
                  " contain symbols not corresponding to amino acids",
                  sep = ""), call. = FALSE)
  }
  
  if (missing(dom_sort)){
    dom_sort <- "abc"
  }
  if (!dom_sort %in% c("ievalue", "abc", "cba")) {
    stop("dom_sort should be one of: 'ievalue', 'abc', 'cba")
  }
  
  areColors <- function(x) {
    sapply(x, function(X) {
      tryCatch(is.matrix(grDevices::col2rgb(X)), 
               error = function(e) FALSE)
    })
  }
  
  if (length(hyp_col) > 1){
    hyp_col <- "#868686FF"
    warning("One color should be provided for hyp_col. Using default: '#868686FF'")
  }
  
  if (!areColors(hyp_col)){
    hyp_col <- "#868686FF"
    warning("hyp_col provided is not a valid color, default will be used: '#868686FF'")
  }
  
  if (length(gpi_col) > 1){
    gpi_col <- "#0073C2FF"
    warning("One color should be provided for gpi_col. Using default: '#0073C2FF'")
  }
  
  if (!areColors(gpi_col)){
    gpi_col <- "#0073C2FF"
    warning("gpi_col provided is not a valid color, default will be used: '#0073C2FF'")
  }
  
  if (length(nsp_col) > 1){
    nsp_col <- "#CD534CFF"
    warning("One color should be provided for nsp_col. Using default: '#CD534CFF'")
  }
  
  if (!areColors(nsp_col)){
    nsp_col <- "#CD534CFF"
    warning("nsp_col provided is not a valid color, default will be used: '#CD534CFF'")
  }
  
  if (length(ag_col) > 1){
    ag_col <- "#E5E5E5FF"
    warning("One color should be provided for ag_col. Using default: '#E5E5E5FF'")
  }
  
  if (!areColors(ag_col)){
    ag_col <- "#E5E5E5FF"
    warning("ag_col provided is not a valid color, default will be used: '#E5E5E5FF'")
  }
  
  if (length(tm_col) > 1){
    tm_col <- "#EFC000FF"
    warning("One color should be provided for tm_col. Using default: '#EFC000FF'")
  }
  
  if (!areColors(tm_col)){
    tm_col <- "#EFC000FF"
    warning("tm_col provided is not a valid color, default will be used: '#EFC000FF'")
  }
  
  if (missing(tm)){
    tm <- TRUE
  }
  if (length(tm) > 1){
    tm <- TRUE
    warning("tm should be of length 1, setting to default: tm = TRUE")
  }
  if (!is.logical(tm)){
    tm <- as.logical(tm)
    warning("tm is not logical, converting using 'as.logical'")
  }
  if (is.na(tm)){
    tm <- TRUE
    warning("tm was set to NA, setting to default: tm = TRUE")
  }
  
  if (missing(nsp)){
    nsp <- TRUE
  }
  if (length(nsp) > 1){
    nsp <- TRUE
    warning("nsp should be of length 1, setting to default: nsp = TRUE")
  }
  if (!is.logical(nsp)){
    nsp <- as.logical(nsp)
    warning("nsp is not logical, converting using 'as.logical'")
  }
  if (is.na(nsp)){
    nsp <- TRUE
    warning("nsp was set to NA, setting to default: nsp = TRUE")
  }
  
  if (missing(ag)){
    ag <- TRUE
  }
  if (length(ag) > 1){
    ag <- TRUE
    warning("ag should be of length 1, setting to default: ag = TRUE")
  }
  if (!is.logical(ag)){
    ag <- as.logical(ag)
    warning("ag is not logical, converting using 'as.logical'")
  }
  if (is.na(ag)){
    ag <- TRUE
    warning("ag was set to NA, setting to default: ag = TRUE")
  }
  
  if (missing(hyp)){
    hyp <- TRUE
  }
  if (length(hyp) > 1){
    hyp <- TRUE
    warning("hyp should be of length 1, setting to default: hyp = TRUE")
  }
  if (!is.logical(hyp)){
    hyp <- as.logical(hyp)
    warning("hyp is not logical, converting using 'as.logical'")
  }
  if (is.na(hyp)){
    hyp <- TRUE
    warning("hyp was set to NA, setting to default: hyp = TRUE")
  }
  
  if (missing(domain)){
    domain <- TRUE
  }
  if (length(domain) > 1){
    domain <- TRUE
    warning("domain should be of length 1, setting to default: domain = TRUE")
  }
  if (!is.logical(domain)){
    domain <- as.logical(domain)
    warning("domain is not logical, converting using 'as.logical'")
  }
  if (is.na(domain)){
    domain <- TRUE
    warning("domain was set to NA, setting to default: domain = TRUE")
  }
  
  if (missing(gpi)){
    gpi <- TRUE
  }
  if (length(gpi) > 1){
    gpi <- TRUE
    warning("gpi should be of length 1, setting to default: gpi = TRUE")
  }
  if (!is.logical(gpi)){
    gpi <- as.logical(gpi)
    warning("gpi is not logical, converting using 'as.logical'")
  }
  if (is.na(gpi)){
    gpi <- TRUE
    warning("gpi was set to NA, setting to default: gpi = TRUE")
  }
  args_signalp <- names(formals(ragp::get_signalp))[4:10]
  args_scanag <- names(formals(ragp::scan_ag))[4:7]
  dots <- list(...)
  
  dat <- data.frame(sequence = sequence,
                    id = id,
                    nchar = nchar(sequence),
                    stringsAsFactors = FALSE)
  
  dat$id <- factor(dat$id,
                   levels = unique(dat$id))
  
  dat$id_num <- as.numeric(dat$id)
  
  if (domain) {
    print("querying hmmscan")
    seq_hmm <- ragp::get_hmm(data = dat,
                             sequence = sequence,
                             id = id,
                             sleep = 0,
                             attempts = 5,
                             verbose = FALSE)
    
    seq_hmm <- seq_hmm[seq_hmm$reported,]
    
    if(nrow(seq_hmm) != 0){
      seq_hmm <- seq_hmm[!is.na(seq_hmm$align_start),]
      
      seq_hmm$id <- factor(seq_hmm$id,
                           levels = unique(dat$id))
      
      seq_hmm$id_num <- as.numeric(seq_hmm$id)
      
      seq_hmm$domain <- with(seq_hmm,
                             paste(desc,
                                   " (",
                                   acc,
                                   ") ",
                                   sep = ""))
      if (dom_sort == "ievalue"){
        seq_hmm <- seq_hmm[with(seq_hmm, order(id_num, as.numeric(ievalue))),]
      }
      if (dom_sort == "abc"){
        seq_hmm <- seq_hmm[with(seq_hmm, order(id_num, name)),]
      }
      if (dom_sort == "cba"){
        seq_hmm <- seq_hmm[with(seq_hmm, order(id_num,
                                               name,
                                               decreasing = c(FALSE, TRUE),
                                               method="radix")),]
      }
    } else {
      seq_hmm <- NULL
    }
  } else {
    seq_hmm <- NULL
  }

  if (nsp) {
    print("querying signalp")
    seq_signalp <- do.call(ragp::get_signalp,
                           c(list(data = dat,
                                  sequence = "sequence",
                                  id = "id"),
                             dots[names(dots) %in% args_signalp]))
    
    seq_signalp <- seq_signalp[seq_signalp$is.signalp,]
    
    if (nrow(seq_signalp) != 0){
      seq_signalp$Ymax.pos <- as.numeric(
        as.character(
          seq_signalp$Ymax.pos
        )
      )
    } else {
      seq_signalp <- NULL
    }
  } else {
    seq_signalp <- NULL
  }
  
  if (tm) {
    print("querying phobius")
    phobius_seq <- ragp::get_phobius(data = dat,
                                     sequence = sequence,
                                     id = id)
    
    phobius_seq <- merge(dat,
                         phobius_seq,
                         by.x = "id",
                         by.y = "Name",
                         sort = FALSE)
    
    phobius_seq_pred <- unlist(
      lapply(strsplit(phobius_seq$prediction,
                      "/"),
             function(x) x[2])
    )
    
    phobius_seq <- data.frame(id = phobius_seq$id, 
                              id_num = phobius_seq$id_num,
                              pred = phobius_seq_pred,
                              is.tm = grepl("\\d+-\\d+",
                                            phobius_seq_pred),
                              seq = phobius_seq$sequence,
                              stringsAsFactors = FALSE)
    
    phobius_seq <- phobius_seq[phobius_seq$is.tm,]
    
    if (nrow(phobius_seq) == 0){
      phobius_seq <- NULL
    } else {
      tm <- stringr::str_extract_all(phobius_seq$pred, "\\d+-\\d+")
      names(tm) <- phobius_seq$id
      
      tm <- lapply(tm, cbind)
      id_tm <- rep(phobius_seq$id_num, sapply(tm, nrow))
      tm <- do.call(rbind, tm)
      tm <- data.frame(tm, id_tm)
      tm$tm_start <- as.numeric(stringr::str_extract(tm$tm, "\\d+(?=-)"))
      tm$tm_end <- as.numeric(stringr::str_extract(tm$tm, "(?<=-)\\d+"))
      
      out <- stringr::str_extract_all(phobius_seq$pred, "\\d+o\\d+|\\d+o")
      out <- lapply(out, cbind)
      id_out <- rep(phobius_seq$id_num, sapply(out, nrow))
      seq_out <- nchar(rep(phobius_seq$seq, sapply(out, nrow)))
      out <- do.call(rbind, out)
      out <- data.frame(out, id_out)
      out$out_start <- as.numeric(stringr::str_extract(out$out, "\\d+(?=o)"))
      out$out_end <- as.numeric(stringr::str_extract(out$out, "(?<=o)\\d+"))
      out$out_end <- ifelse(is.na(out$out_end), seq_out, out$out_end)
      
      inside <- stringr::str_extract_all(phobius_seq$pred, "\\d+i\\d+|\\d+i")
      inside <- lapply(inside, cbind)
      id_inside <- rep(phobius_seq$id_num, sapply(inside, nrow))
      seq_inside <- nchar(rep(phobius_seq$seq, sapply(inside, nrow)))
      inside <- do.call(rbind, inside)
      inside <- data.frame(inside, id_inside)
      inside$inside_start <- as.numeric(stringr::str_extract(inside$inside, "\\d+(?=i)"))
      inside$inside_end <- as.numeric(stringr::str_extract(inside$inside, "(?<=i)\\d+"))
      inside$inside_end <- ifelse(is.na(inside$inside_end), seq_inside, inside$inside_end)
    }
  } else {
    phobius_seq <- NULL
  }

  if (gpi) {
    print("querying big pi")
    seq_gpi <- ragp::get_big_pi(dat,
                                "sequence",
                                "id")
    
    seq_gpi <- seq_gpi[seq_gpi$is.bigpi,]
    
    
    if (nrow(seq_gpi) == 0) {
      seq_gpi <- NULL
    }
  } else {
    seq_gpi <- NULL
  }
  
  
  if (hyp) {
    seq_hyp <- do.call(ragp::predict_hyp,
                       c(list(data = dat,
                              sequence = "sequence",
                              id = "id"),
                         dots[names(dots) == "tprob"])
    )$prediction
    
    if (!is.null(seq_hyp)) {
      seq_hyp <- seq_hyp[seq_hyp$HYP == "Yes",]
    }
    
    if (!is.null(seq_hyp) && nrow(seq_hyp) == 0) {
      seq_hyp <- NULL
    }
  } else {
    seq_hyp <- NULL
  }
    
  if (ag) {
    seq_scan <- do.call(ragp::scan_ag,
                        c(list(data = dat,
                               sequence = "sequence",
                               id = "id",
                               simplify = FALSE,
                               tidy = TRUE),
                          dots[names(dots) %in% args_scanag]))
    
    seq_scan <- seq_scan[, -5]
    seq_scan <- seq_scan[!is.na(seq_scan$location.start),]
    
    if (nrow(seq_scan) == 0) {
      seq_scan <- NULL
    }
  } else {
    seq_scan <- NULL
  }
  
  if (!is.null(seq_gpi)){
    for_plot <- merge(x = dat,
                      y = seq_gpi,
                      by = "id",
                      all.x = TRUE,
                      all.y = FALSE,
                      sort = FALSE)
  } else {
    for_plot <- dat
  }
  
  if (!is.null(seq_signalp)){
    for_plot <- merge(for_plot,
                      seq_signalp,
                      by = "id",
                      all.x = TRUE,
                      all.y = FALSE,
                      sort = FALSE)
  } else {
    for_plot <- for_plot
  }
  
  if (!is.null(dim(seq_hyp))){
    for_plot <- merge(for_plot,
                      seq_hyp,
                      by = "id",
                      all.x = TRUE,
                      all.y = FALSE,
                      sort = FALSE)
  } else {
    for_plot <- for_plot 
  }
  
  if (!is.null(dim(seq_scan))){
    for_plot <- merge(for_plot,
                      seq_scan,
                      by = "id",
                      all.x = TRUE,
                      all.y = FALSE,
                      sort = FALSE)
  } else {
    for_plot <- for_plot
  }
  
  lims <- c("N-sp", "omega site (gpi)", "hyp", "AG span", "TM")
  vals <- c(nsp_col, gpi_col, hyp_col, ag_col, tm_col)
  labs <- c("N-sp", "omega site (gpi)", "hyp", "AG span", "TM")
  
  subs <- c(!is.null(seq_signalp),
            !is.null(seq_gpi),
            !is.null(seq_hyp),
            !is.null(seq_scan),
            !is.null(phobius_seq))
  
  if (any(subs)){
    lims <- lims[subs]
    vals <- vals[subs]
    labs <- labs[subs]
  } else {
    lims <- NA
    vals <- NA
    labs <- NULL
  }
  
  p <- ggplot2::ggplot(for_plot)+
    ggplot2::geom_segment(ggplot2::aes_(y = ~id_num,
                                        yend = ~id_num,
                                        x = 1,
                                        xend = ~nchar)) +
    ggplot2::xlab("residue") +
    ggplot2::ylab("id") +
    ggplot2::scale_y_continuous(breaks = seq_along(id),
                                labels = id,
                                limits = c(0.5, length(id) + 0.5)) +
    ggplot2::theme_bw()+
    ggplot2::theme(panel.grid = ggplot2::element_blank(),
                   panel.border = ggplot2::element_blank(),
                   axis.ticks.y = ggplot2::element_blank(),
                   axis.line.x = ggplot2::element_line()) +
    ggplot2::coord_equal(ratio = 20,
                         expand = FALSE)
  
  if(!is.null(phobius_seq)){
    p <-  p +
      ggplot2::geom_rect(data = tm,
                         ggplot2::aes_(ymin = ~id_tm - 0.35,
                                       ymax = ~id_tm + 0.35,
                                       xmin = ~tm_start,
                                       xmax = ~tm_end, color = "TM"),
                         fill = tm_col,
                         na.rm = TRUE) +
      ggplot2::geom_segment(data = inside,
                            ggplot2::aes_(y = ~id_inside - 0.35,
                                          yend = ~id_inside - 0.35,
                                          x = ~inside_start,
                                          xend = ~inside_end),
                            lty = 2,
                            na.rm = TRUE)+
      ggplot2::geom_segment(data = out,
                            ggplot2::aes_(y = ~id_out + 0.35,
                                          yend = ~id_out + 0.35,
                                          x = ~out_start,
                                          xend = ~out_end),
                            lty = 2,
                            na.rm = TRUE)
  }
  
  if(!is.null(seq_hmm)) {
    p <- p + 
      ggplot2::geom_rect(data = seq_hmm,
                         ggplot2::aes_(ymin = ~id_num - 0.25,
                                       ymax = ~id_num + 0.25,
                                       xmin = ~align_start,
                                       xmax = ~align_end,
                                       fill = ~domain),
                         colour = "grey20",
                         na.rm = TRUE)
  }
  
  
  if(!is.null(seq_signalp)) {
    p <- p +
      ggplot2::geom_segment(ggplot2::aes_(y = ~id_num,
                                          yend = ~id_num,
                                          x = 1,
                                          xend = ~Ymax.pos,
                                          color = "N-sp"),
                            size = 2,
                            na.rm = TRUE)
    } 
  
  if(!is.null(seq_scan)) {
    p <- p +
      ggplot2::geom_rect(ggplot2::aes_(ymin = ~id_num - 0.18,
                                       ymax = ~id_num + 0.18,
                                       xmin = ~location.start,
                                       xmax = ~location.end,
                                       color = "AG span"),
                         fill = ag_col,
                         na.rm = TRUE) 
  } 
  
  if(!is.null(seq_hyp)) {
    p <- p +
      ggplot2::geom_errorbar(ggplot2::aes_(ymin = ~id_num - 0.18,
                                           ymax = ~id_num + 0.18,
                                           x  = ~P_pos,
                                           color = "hyp"),
                             size = 1,
                             width = 0,
                             na.rm = TRUE)
  }
  
  if(!is.null(seq_gpi)) {
    p <- p +
      ggplot2::geom_point(ggplot2::aes_(y = ~id_num,
                                        x = ~omega_site,
                                        color = "omega site (gpi)"),
                          shape = 18,
                          size = 4,
                          na.rm = TRUE) 
    } 
  
  p <- p +
    ggplot2::scale_color_manual("feature",
                                limits = lims,
                                values = vals,
                                labels = labs)
  
  p <- p + 
    ggplot2::guides(color = ggplot2::guide_legend(keywidth = 1,
                                                  keyheight = 1,
                                                  override.aes = list(size = 5,
                                                                      shape = 15,
                                                                      linetype = 1)))
  
  
  return(p)
}


