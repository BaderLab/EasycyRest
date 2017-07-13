#' Format the Enrichment map - move all red (NES +ve nodes) to the right and
#' all blue (NES -ve nodes) to the left
#'
#' @param base.url cyrest base url for communicating with cytoscape
#' @param  suid of the network that you want to get the view for
#' @return server response
#' @export
#' @import RJSONIO
#' @import httr
formatEnrichmentmap <- function(network='current', base.url='http://localhost:1234/v1'){

  #get the nodes table
  nodes_info <- getNodeTable(base.url, network)

  #get the column name that has the NES values
  nes_column = grep(pattern="NES", colnames(nodes_info))

  #select all the positive NES nodes and move them to the right
  nodes_to_select <- nodes_info[which(nodes_info[,nes_column] > 0),]

  #get the view info
  network.viewid <- getNetworkviewId(network=network,base.url = base.url)
  node_positions <- getNodeviewTable(network.viewid = network.viewid, network=network, base.url = base.url)
  x.offset = (max(as.numeric(node_positions[,"position.x"])) - min(as.numeric(node_positions[,"position.x"])))/2

  if(!is.null(nodes_to_select) & length(nodes_to_select) > 0){
    #select nodes
    response <- selectNodes(nodes = nodes_to_select,network = network, base.url = base.url)

    #move selected nodes so they don't overlap other groups
    response <- cyMoveSelectedNodes(base.url = base.url, network.suid = network,
                                       x.offset=x.offset,network.viewid = network.viewid)
  }

  #select all the positive NES nodes and move them to the right
  nodes_to_select <- nodes_info[which(nodes_info[,nes_column] < 0),]

  if(!is.null(nodes_to_select) & length(nodes_to_select) > 0){
    #select nodes
    response <- selectNodes(nodes = nodes_to_select,network = , base.url = base.url)

    #move selected nodes so they don't overlap other groups
    response <- moveSelectedNodes(base.url = base.url, network = ,
                                       x.offset=(-x.offset),network.viewid = network.viewid)
  }


}
