const app = Elm.Main.embed(
  document.getElementById('elm-app')
)

const searchGithub = query =>
  fetch(query)
    .then(res => res.json())
    .then(repos => app.ports.responseFromGithubApiWithJS.send(repos))

app.ports.searchGithubApiWithJS.subscribe(searchGithub)
