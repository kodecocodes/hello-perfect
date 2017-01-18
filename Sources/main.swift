import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let server = HTTPServer()
var routes = Routes()

func returnJSONMessage(message: String, response: HTTPResponse) {
  response.setHeader(.contentType, value: "application/json")
  do {
    try response.setBody(json: ["message": message])
  } catch {
    response.status = .internalServerError
    response.setBody(string: "Error handling request: \(error)")
  }
  response.completed()
}

routes.add(method: .get, uri: "/", handler: {
  request, response in
  returnJSONMessage(message: "Hello, Perfect!", response: response)
})

routes.add(method: .get, uri: "/hello", handler: {
  request, response in
  returnJSONMessage(message: "Hello, again!", response: response)
})

routes.add(method: .get, uri: "/hello/there", handler: {
  request, response in
  returnJSONMessage(message: "I am tired of saying hello!", response: response)
})

routes.add(method: .get, uri: "/beers/{num_beers}", handler: {
  request, response in
  guard let numBeersString = request.urlVariables["num_beers"],
    let numBeersInt = Int(numBeersString) else {
    response.status = .badRequest
    response.completed()
    return
  }
  returnJSONMessage(message: "Take one down, pass it around, \(numBeersInt - 1) bottles of beer on the wall...", response: response)
})

routes.add(method: .post, uri: "post", handler: {
  request, response in
  guard let name = request.param(name: "name") else {
    response.status = .badRequest
    response.completed()
    return
  }
  returnJSONMessage(message: "Hello, \(name)!", response: response)
})

server.addRoutes(routes)
server.serverPort = 8080

do {
  try server.start()
} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}
