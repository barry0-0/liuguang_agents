import Foundation

/// The proxy variables a CLI reads, and the ones it cannot start with.
///
/// Pi's HTTP client, undici, accepts a proxy address that starts with `http:` or `https:` and nothing else. A proxy
/// set up as `socks5h://` makes it throw before the CLI shows anything, so Pi never starts. The `socks5` scheme
/// names the same proxy and works.
enum CLIProxyEnvironment {
    private static let variableNames = ["HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "http_proxy", "https_proxy", "all_proxy"]
    private static let unsupportedScheme = "socks5h://"
    private static let supportedScheme = "socks5://"

    /// The environment a CLI starts with, with the proxy addresses it cannot read replaced.
    static func supportedProxyAddresses(in environment: [String: String]) -> [String: String] {
        var environment = environment
        for name in variableNames {
            guard let value = environment[name], value.lowercased().hasPrefix(unsupportedScheme) else { continue }
            environment[name] = supportedScheme + value.dropFirst(unsupportedScheme.count)
        }
        return environment
    }
}
