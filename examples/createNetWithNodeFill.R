# creates network in cytoscape through cyrest.
# applies spring-embedded layout. 
# The CyREST API is here: http://idekerlab.github.io/cyREST/

require(httr)
require(RJSONIO)
require(EasycyRest)

# test connection with Cytoscape
port.number = 1234
base.url = paste("http://localhost:", toString(port.number), "/v1", sep="")
version.url = paste(base.url, "version", sep="/")
cytoscape.version = GET(version.url)
cy.version = fromJSON(rawToChar(cytoscape.version$content))
print(cy.version)

# set up network
mynodes <- data.frame(Alias=c("A","B","C","D"), 
	GROUP=c("YES","YES","NO","NO"),
	stringsAsFactors=FALSE)
myedges <- data.frame(AliasA=c("A","A","B"), AliasB=c("B","C","C"),
	weight=c(1,0.5,0.7),stringsAsFactors=FALSE)
netName <- "myNetwork"
collName <- "myCollection"

# ----------------------------------------------------------------

cat("Make nodes\n")
json_nodes <- nodeSet2JSON(mynodes)
cat("Make edges\n")
json_edges <- edgeSet2JSON(myedges)
cat("Make network\n")
json_network <- list(
    data=list(name="myNetwork"),
    elements=c(nodes=list(json_nodes),edges = list(json_edges))
)
network <- toJSON(json_network)

cat("* Create network URL\n")
create.url <- paste(base.url,"networks", sep="/") 
urlparam <- paste(create.url, "?title=", netName, 
									"&collection=",collName,sep="")
print(urlparam)

### This is the call to generate the network in Cytoscape
cat("* POSTing to create net in Cytoscape\n")
response <- POST(url=urlparam,body=network, encode="json")

# now get the network ID (or handle) so you can apply operations to this net
network.suid <- unname(fromJSON(rawToChar(response$content)))
cat(sprintf("Network ID is : %i \n", network.suid))

# to see full list of layouts, in your web browser type:
# http://localhost:1234/v1/apply/layouts
# to see parameters for a given layout, type:
# http://localhost:1234/v1/apply/layouts/kamada-kawai
cat("* Applying spring-embedded layout\n")
layout.url <- sprintf("%s/apply/layouts/kamada-kawai/%s?column=weight",
										base.url,network.suid, sep="/")
print(layout.url)
response <- GET(url=layout.url) 
rawToChar(response$content)

# node style - colour nodes by GROUP attribute
cat("* Creating style\n")

styleName <- "myStyle"
nodeFills <- map_NodeFillDiscrete("GROUP",c("YES","NO"),c("#FF9900","#3300CC"))
style <- list(title=styleName, mappings=list(nodeFills))
jsonStyle <- toJSON(style)

style.url <- sprintf("%s/styles",base.url)
POST(url=style.url,body=jsonStyle, encode="json")

cat("* Apply style\n")
apply.style.url <- sprintf("%s/apply/styles/%s/%i",base.url, styleName,
													 network.suid)
print(apply.style.url)
GET(apply.style.url)

