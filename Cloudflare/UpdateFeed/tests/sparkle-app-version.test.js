import assert from "node:assert/strict";
import { test } from "node:test";

import { readAppVersionFromSparkleUserAgent } from "../src/sparkle-app-version.js";

test("reads the app version from Sparkle's user agent", () => {
    assert.equal(readAppVersionFromSparkleUserAgent("Liuguang/0.36.1 Sparkle/2.10.0"), "0.36.1");
});

test("ignores clients other than Liuguang's Sparkle", () => {
    const otherUserAgents = [
        null,
        "",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15",
        "curl/8.7.1",
        "OtherApp/1.2.3 Sparkle/2.10.0",
        "Liuguang/0.36.1",
        "Liuguang/? Sparkle/2.10.0",
    ];
    for (const userAgent of otherUserAgents) {
        assert.equal(readAppVersionFromSparkleUserAgent(userAgent), null, String(userAgent));
    }
});

test("keeps no free-form text from a malformed version", () => {
    assert.equal(readAppVersionFromSparkleUserAgent("Liuguang/0.36.1-anything Sparkle/2.10.0"), null);
    assert.equal(readAppVersionFromSparkleUserAgent("Liuguang/12345.0.0 Sparkle/2.10.0"), null);
    assert.equal(readAppVersionFromSparkleUserAgent("Liuguang/0.36.1 Sparkle/2.10.0 extra"), null);
});
