#' Resource type -suodattimet omana apufunktiona
#' Palauttaa SPARQL FILTER-lausekkeen resource_type-arvon perusteella,
#' tai NULL jos resource_type == "any" (ei suodatinta tarvita)
#'
#' @noRd
get_resource_type_filter <- function(resource_type, manual_type = "") {
  
  if (resource_type == "directive"){
    return("FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/DIR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_DEL>)")
  }
  
  if (resource_type == "recommendation"){
    return("FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/RECO>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_DEC>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_DIR>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_OPIN>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_RES>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_REG>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_RECO>||
                   ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_DRAFT>)")
  }
  
  if (resource_type == "regulation"){
    return("FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/REG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_FINANC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_DEL>)")
  }
  
  if (resource_type == "intagr"){
    return("FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_INTERNATION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/EXCH_LET>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_PROT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ACT_ADOPT_INTERNATION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ARRANG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/CONVENTION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_AMEND>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_ADOPT_INTERNATION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_ADOPT_INTERNATION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_ADOPT_INTERNATION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/MEMORANDUM_UNDERST>)")
  }
  
  if (resource_type == "decision"){
    return("FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/DEC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_ENTSCHEID>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_DEL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_FRAMW>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_DEC>)")
  }
  
  if (resource_type == "caselaw"){
    return("FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/JUDG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ORDER>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/OPIN_JUR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/THIRDPARTY_PROCEED>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/GARNISHEE_ORDER>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/RULING>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JUDG_EXTRACT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/INFO_JUDICIAL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/VIEW_AG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/OPIN_AG>)")
  }
  
  if (resource_type == "proposal"){
    return("FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DIR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_REG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DEC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DEC_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_REG_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DIR_IMPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_RECO>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_PROP_DEC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_PROP_ACTION>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_PROP_REG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_PROP_DIR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_RES>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_AMEND>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_OPIN>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DECLAR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DEC_FRAMW>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_DEL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/RECO_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/RES_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_IMPL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_IMPL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_IMPL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DIR_DEL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/REG_DEL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ACT_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ACT_DEL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/ACT_IMPL_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DECLAR_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/DEC_FRAMW_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/JOINT_ACTION_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROT_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/COMMUNIC_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_EUMS_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_INTERINSTIT_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_INTERNATION_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AGREE_UBEREINKOM_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/BUDGET_DRAFT>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/BUDGET_DRAFT_PRELIM>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/BUDGET_DRAFT_PRELIM_SUPPL>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/BUDGET_DRAFT_SUPPL_AMEND>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AMEND_PROP>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AMEND_PROP_DIR>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AMEND_PROP_REG>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/AMEND_PROP_DEC>||
  ?type=<http://publications.europa.eu/resource/authority/resource-type/PROP_DEC_NO_ADDRESSEE>)")
  }
  
  if (resource_type == "national_impl"){
    return("FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/MEAS_NATION_IMPL>)")
  }
  
  if (nchar(manual_type) > 1 & resource_type == "manual"){
    return(paste0("FILTER(?type=<http://publications.europa.eu/resource/authority/resource-type/", manual_type, ">)"))
  }
  
  return(NULL)  # "any" -> ei suodatinta
}