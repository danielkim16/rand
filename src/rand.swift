import Foundation
import Security

private let groups = [
    Array("abcdefghijklmnopqrstuvwxyz"),
    Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ"),
    Array("0123456789"),
    Array("!@#$%^&*"),
]
private let characters = groups.flatMap { $0 }
private let defaultPasswordLength = 12
private let maximumPasswordLength = 4096

private enum PasswordError: Error {
    case randomBytesUnavailable(OSStatus)
}

private func secureRandomIndex(upperBound: Int) throws -> Int {
    precondition(upperBound > 0 && upperBound <= 256)
    let limit = 256 - (256 % upperBound)

    while true {
        var byte: UInt8 = 0
        let status = SecRandomCopyBytes(kSecRandomDefault, 1, &byte)
        guard status == errSecSuccess else {
            throw PasswordError.randomBytesUnavailable(status)
        }
        if Int(byte) < limit {
            return Int(byte) % upperBound
        }
    }
}

private func generatePassword(length: Int) throws -> String {
    while true {
        var password: [Character] = []
        password.reserveCapacity(length)

        for _ in 0..<length {
            password.append(characters[try secureRandomIndex(upperBound: characters.count)])
        }

        if groups.allSatisfy({ group in password.contains(where: group.contains) }) {
            return String(password)
        }
    }
}

@main
private struct Rand {
    private static let help = """
        Usage: rand [LENGTH]
               rand [-l | --length] LENGTH
               rand [-h | --help]

        Generate a password containing at least one lowercase letter, uppercase
        letter, digit, and special character (!@#$%^&*).

        LENGTH defaults to 12 and must be between 4 and 4096.

        Options:
          -l, --length  Set the password length.
          -h, --help  Show this help message.
        """

    private static func passwordLength(from arguments: [String]) -> Int? {
        if arguments.isEmpty {
            return defaultPasswordLength
        }

        let value: String
        if arguments.count == 1 {
            value = arguments[0]
        } else if arguments.count == 2 && ["-l", "--length"].contains(arguments[0]) {
            value = arguments[1]
        } else {
            return nil
        }

        guard let length = Int(value), (groups.count...maximumPasswordLength).contains(length) else {
            return nil
        }
        return length
    }

    static func main() {
        let arguments = Array(CommandLine.arguments.dropFirst())
        if arguments == ["--help"] || arguments == ["-h"] {
            print(help)
            return
        }
        guard let length = passwordLength(from: arguments) else {
            FileHandle.standardError.write(Data("Invalid arguments.\n\n\(help)\n".utf8))
            exit(2)
        }

        do {
            print(try generatePassword(length: length))
        } catch {
            FileHandle.standardError.write(Data("Could not generate a secure password: \(error)\n".utf8))
            exit(EXIT_FAILURE)
        }
    }
}
