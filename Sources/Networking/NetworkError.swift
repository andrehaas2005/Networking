import Foundation

public enum NetworkError: Error {
  case invalidURL
  case requestFailed(Error)
  case decodingFailed(Error)
  case httpError(Int)
  case unknown
  public func descript() -> String {
    var errorMessage = ""
    switch self {
    case .httpError(let code):
      errorMessage = "Erro HTTP: \(code)"
    case .decodingFailed:
      errorMessage = "Erro ao ler resposta do servidor."
    case .invalidURL:
      errorMessage = "URL inválida."
    case .requestFailed(let underlying):
      errorMessage = "Falha na requisição: \(underlying.localizedDescription)"
    default:
      errorMessage = "Erro de rede. Tente novamente."
    }
    return errorMessage
  }
}

