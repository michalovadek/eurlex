#' Retrieve Council votes on EU acts
#' NOTE: The Council votes API was discontinued in May 2024.
#'
#' Executes a SPARQL query to the Council's endpoint.
#'
#' @noRd
#'

elx_council_votes <- function() {
       query <- "PREFIX acts: <http://data.consilium.europa.eu/id/acts/>
            PREFIX tax: <http://data.consilium.europa.eu/id/taxonomy/>
            PREFIX codi: <http://data.consilium.europa.eu/def/codi/>
            PREFIX skos:<http://www.w3.org/2004/02/skos/core#>
            PREFIX dct: <http://purl.org/dc/terms/>
            PREFIX foaf: <http://xmlns.com/foaf/0.1/>
            PREFIX owl: <http://www.w3.org/2002/07/owl#>
            PREFIX votpos: <http://data.consilium.europa.eu/id/taxonomy/votingposition>
            SELECT distinct ?voteProc ?votingRuleLabel ?policyAreaLabel ?voteOnDocumentNumber ?votingInstCode ?legisProcLabel ?decisionDate ?meetingSessionNumber ?councilConfigurationLabel  ?docExpression ?docTitle ?registerPage ?actNumber ?actTypeLabel ?voteDecision group_concat(distinct ?councilActionLabel;separator='|') as ?councilActionLabelGrouped  group_concat(distinct ?countryCodeInFavour;separator='|') as ?countryCodeInFavourGrouped  group_concat(distinct ?countryCodeAgainst;separator='|') as ?countryCodeAgainstGrouped  group_concat(distinct ?countryCodeAbstained;separator='|') as ?countryCodeAbstainedGrouped  group_concat(distinct ?countryCodeNotParticipating;separator='|') as ?countryCodeNotParticipatingGrouped
            FROM <http://data.consilium.europa.eu/id/dataset/VotingResults>
            FROM <http://data.consilium.europa.eu/id/dataset/PublicRegister>
            WHERE {
               ?voteProc a codi:VotingProcedure.
               ?voteProc codi:votingRule ?votingRule.
               ?votingRule skos:prefLabel ?votingRuleLabel
               optional {
                      ?voteProc codi:policyArea ?policyArea.
                      ?policyArea skos:prefLabel ?policyAreaLabel
               }.
               optional {
                      ?voteProc codi:voteOn ?voteOn.
                      FILTER (CONTAINS(STR(?voteOn), 'INIT')).
                      ?voteOn codi:document_number ?voteOnDocumentNumber.
                      optional { ?voteOn codi:act_number ?actNumber. }.
                      optional {
                             ?voteOn codi:actType ?actType.
                             ?actType skos:prefLabel ?actTypeLabel.
                      }.
                      optional { ?voteOn foaf:page ?registerPage. }
                      ?voteOn codi:expressed ?docExpression.
                      ?docExpression dct:title ?docTitle.
                      ?docExpression dct:language ?docLanguage.
                      FILTER ( lang(?docTitle) = 'en' )
               }.
                     optional { ?voteProc codi:forInterInstitutionalCode ?votingInstCode }.
                     ?voteProc codi:legislativeProcedure ?legisProc.
                     ?legisProc skos:prefLabel ?legisProcLabel.
                     ?voteProc codi:hasVoteOutcome ?voteDecision.
                     ?voteDecision dct:dateAccepted ?decisionDate.
                optional {
                    ?voteDecision codi:councilAction ?councilAction.
                             ?councilAction skos:prefLabel ?councilActionLabel.
                }.
             optional {
                    ?meeting codi:appliesProcedure ?voteProc.
                    optional { ?meeting codi:meetingsessionnumber ?meetingSessionNumber. }
                    optional {
                           ?meeting codi:configuration ?meetingConfig.
                           ?meetingConfig a skos:Concept.
                           ?meetingConfig skos:prefLabel ?councilConfigurationLabel.
                    }
             }.
             ?voteDecision codi:hasVotingPosition ?countryVote_uri .
             optional {
                    ?countryVote_uri codi:votingposition <http://data.consilium.europa.eu/id/taxonomy/votingposition/votedagainst>.
                    ?countryVote_uri codi:country ?countryVoteAgainst_uri.
                    ?countryVoteAgainst_uri skos:notation ?countryCodeAgainst.
             }
             optional {
                    ?countryVote_uri codi:votingposition <http://data.consilium.europa.eu/id/taxonomy/votingposition/votedinfavour>.
                    ?countryVote_uri codi:country ?countryVoteInFavour_uri.
                    ?countryVoteInFavour_uri skos:notation ?countryCodeInFavour.
             }
             optional {
                    ?countryVote_uri codi:votingposition <http://data.consilium.europa.eu/id/taxonomy/votingposition/abstained>.
                    ?countryVote_uri codi:country ?countryAbstained_uri.
                    ?countryAbstained_uri skos:notation ?countryCodeAbstained.
             }
             optional {
                    ?countryVote_uri codi:votingposition <http://data.consilium.europa.eu/id/taxonomy/votingposition/notparticipating>.
                    ?countryVote_uri codi:country ?countryNotParticipating_uri.
                    ?countryNotParticipating_uri skos:notation ?countryCodeNotParticipating.
                 }
          }
              ORDER BY DESC(?decisionDate), ?votingInstCode
"

       # # run query
       # votes_resp <- graceful_http(
       #   remote_file = "https://data.consilium.europa.eu/sparql",
       #   body = list(query = query),
       #   httr::content_type("multipart"),
       #   headers = httr::add_headers('Accept' = 'text/csv'),
       #   encode = "multipart",
       #   verb = "POST"
       # )
       #
       # # if var not created, break
       # if (is.null(votes_resp)){
       #
       #   return(invisible(NULL))
       #
       # }
       #
       # # process response
       # votes <- votes_resp %>%
       #   httr::content("text") %>%
       #   readr::read_csv(col_types = readr::cols(.default = "c"))
       #
       # # return
       # return(votes)

       return("The Council votes API was discontinued in May 2024.")
}
