import Foundation
import Testing

@testable import Liuguang

struct CLIProxyEnvironmentTests {
    @Test func replacesTheSchemePiCannotRead() {
        let environment = CLIProxyEnvironment.supportedProxyAddresses(in: [
            "HTTP_PROXY": "socks5h://127.0.0.1:7890",
            "HTTPS_PROXY": "socks5h://127.0.0.1:7890",
            "ALL_PROXY": "socks5h://127.0.0.1:7890",
            "NO_PROXY": "localhost",
        ])

        #expect(environment["HTTP_PROXY"] == "socks5://127.0.0.1:7890")
        #expect(environment["HTTPS_PROXY"] == "socks5://127.0.0.1:7890")
        #expect(environment["ALL_PROXY"] == "socks5://127.0.0.1:7890")
        #expect(environment["NO_PROXY"] == "localhost")
    }

    @Test func keepsTheLowercaseNamesAndTheSchemesThatWork() {
        let environment = CLIProxyEnvironment.supportedProxyAddresses(in: [
            "http_proxy": "socks5h://127.0.0.1:7890",
            "https_proxy": "http://127.0.0.1:7890",
            "all_proxy": "socks5://127.0.0.1:7890",
        ])

        #expect(environment["http_proxy"] == "socks5://127.0.0.1:7890")
        #expect(environment["https_proxy"] == "http://127.0.0.1:7890")
        #expect(environment["all_proxy"] == "socks5://127.0.0.1:7890")
    }

    @Test func leavesAnEnvironmentWithoutProxiesAlone() {
        let environment = CLIProxyEnvironment.supportedProxyAddresses(in: ["PATH": "/usr/bin"])

        #expect(environment == ["PATH": "/usr/bin"])
    }
}
