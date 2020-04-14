## 下拉式選單

<summary>Swift Package Manager</summary>
</br>
<p>You can use <a href="https://swift.org/package-manager">The Swift Package Manager</a> to install <code>RDropDownMenu</code> by adding the proper description to your <code>Package.swift</code> file:</p>

<pre><code class="swift language-swift">import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    targets: [],
    dependencies: [
        .package(url: "https://github.com/ChenYenChen/RDropDownMenu", from: "1.0.0")
    ]
)
</code></pre>

<p>Next, add <code>RDropDownMenu</code> to your targets dependencies like so:</p>
<pre><code class="swift language-swift">.target(
    name: "YOUR_TARGET_NAME",
    dependencies: [
        "RDropDownMenu",
    ]
),</code></pre>
<p>Then run <code>swift package update</code>.</p>

<p>Note that the <a href="https://swift.org/package-manager">Swift Package Manager</a> doesn't support building for iOS/tvOS/macOS/watchOS apps – see Accio in the next section for that.


