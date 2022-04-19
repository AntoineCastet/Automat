###############################################################################
######################  SCRAPING IDEAS-REPEC : un exemple #####################
######################   Author : Jean-Baptiste GUIFFARD  #####################
###############################################################################



# Package
# Installation
#install.packages("rvest")

library(rvest)


# Définir une variable correspondant au nom de la page des économistes référencés NEP.DEV
url_authors <- "https://ideas.repec.org/i/edev.html"

# Récupération de la liste des auteurs NEP.DEV
html_authors <- read_html(url_authors, encoding="UTF-8")

liste_authors <- html_nodes(html_authors,"td") %>% html_nodes("a") %>% html_text() #noms

liste_links <- html_nodes(html_authors,"td") %>% html_nodes("a") %>% html_attr('href') #liens vers pages persos


df_authors <- data.frame(authors = liste_authors,
                         href = liste_links,
                         affiliation = rep(NA, length(liste_authors)),
                         location = rep(NA, length(liste_authors)))

dim(df_authors)
View(df_authors)

# Sélection auteurs (20-30)

df_authors_select <- df_authors[c(20:30),]



# Un exemple de boucle

url_base <- "https://ideas.repec.org"

for (author_n in 1:nrow(df_authors_select)){
  print(df_authors_select[author_n,"authors"])
  URL_author <- paste(url_base, df_authors_select[author_n,'href'], sep="")
}




for (author_n in 1:nrow(df_authors_select)){
  print(df_authors_select[author_n,"authors"])
  URL_author <- paste(url_base, df_authors_select[author_n,'href'], sep="")
  HTML_author <- read_html(URL_author, encoding="UTF-8")
  
  affiliation_author <- html_nodes(HTML_author,"div") %>%html_nodes(css = "div[id='affiliation']") %>% html_nodes("h3") %>% html_text()

  location_author <- html_nodes(HTML_author,"div") %>%html_nodes(css = "div[id='affiliation']") %>%html_nodes(css = "span[class='locationlabel']") %>% html_text()

  df_authors_select[author_n,"affiliation"] <- affiliation_author[1]
  df_authors_select[author_n,"location"] <- location_author[1]

  }
  

View(df_authors_select)











