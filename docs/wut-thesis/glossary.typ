// this is an example. Check https://typst.app/universe/package/glossarium

#let glossary = (
  (
    key: "silesian",
    short: "Silesian Deception Detection Dataset",
    long: "Silesian Deception Detection Dataset",
    description: "Zbiór danych zawierający nagrania wideo przedstawiające osoby mówiące prawdę, bądź kłamiące. Nagrania powstały z użyciem profesjonalnej kamery w kontrolowanych warunkach laboratoryjnych na Politechnice Śląskiej.",
  ),
  (
    key: "real_life_ddd",
    short: "Real-Life Deception Detection Dataset",
    long: "Real-Life Deception Detection Dataset",
    description: "Zbiór danych zawierający nagrania wideo z prawdziwych sytuacji, w których osoby były nagrywane podczas mówienia prawdy lub kłamstwa. Nagrania pochodzą z różnych źródeł, takich jak programy telewizyjne, wywiady czy materiały z procesu sądowego. Są gorszej jakości niż nagrania z Silesian Deception Detection Dataset, lecz bardziej reprezentatywne dla rzeczywistych sytuacji.",
  )
  // minimal term
  // (key: "wut", short: "WUT", long: "Warsaw University of Technology"),
  // a term with a long form
  // (key: "goat", short: "GOAT", long: "greatest of all time"),
  // no long form here
  // (key: "kdecom", short: "KDE Community", description:"An international team developing and distributing Open Source software."),
  // a full term with description containing markup
  // (
  //   key: "oidc", 
  //   short: "OIDC", 
  //   long: "OpenID Connect", 
  //   description: [OpenID is an open standard and decentralized authentication protocol promoted by the non-profit
  //    #link("https://en.wikipedia.org/wiki/OpenID#OpenID_Foundation")[OpenID Foundation].]),
)
