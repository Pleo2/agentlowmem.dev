# agentlowmem.dev

The public website for [Agent Lowmem](https://github.com/Pleo2/agent-lowmem): a native policy runner for predictable agent-launched validation on memory-constrained Apple Silicon Macs.

## Principles

- one production HTML response;
- zero production JavaScript;
- zero downloaded fonts or images;
- less than 15 KiB after gzip compression;
- system-adaptive light and dark themes;
- no continuous animation.

## Preview

```sh
python3 -m http.server 4173 --bind 127.0.0.1
```

Open `http://127.0.0.1:4173/`.

## Verify

```sh
./tests/verify-site.sh
./scripts/verify-site.sh index.html
```

## Roadmap

The initial release remains one lightweight landing page. Future work is tracked in this order.

### Before the CLI release

- [ ] Select licenses for the CLI and website repositories without assuming MIT in advance.
- [ ] Record reproducible landing-release evidence: commit, deployment, compressed size, response headers, and Lighthouse results.
- [ ] Complete the final Safari, Chrome, mobile-width, 200% zoom, and theme review.

### When the CLI is released

- [ ] Make `Pleo2/agent-lowmem` public and point product-source links to it.
- [ ] Replace the profile-follow action with a working installation command and release link.
- [ ] Replace the prerelease status with the published version and verified platform support.
- [ ] Align the terminal example exactly with the released CLI output.

### Search and FAQ

- [ ] Verify `agentlowmem.dev` in Google Search Console, submit the sitemap, and collect real query data before selecting target keywords.
- [ ] Add a useful FAQ covering what Agent Lowmem is, how it controls memory pressure, supported tools and platforms, process safety, `sudo`, watch mode, installation, Rust, and open-source status.
- [ ] Publish only search-intent pages backed by distinct user needs and original examples. Initial candidates are:
  - `/macbook-air-8gb-coding-agents`
  - `/reduce-node-memory-usage-macos`
  - `/run-tests-with-less-ram`
  - `/prevent-jest-vitest-memory-spikes`
  - `/managed-runner-for-ai-agents`
  - `/low-memory-javascript-testing`
- [ ] Give every published page a unique title, description, canonical URL, visible internal navigation, and sitemap entry.
- [ ] Preserve static output, zero production JavaScript, and a measured transfer budget on every route.
- [ ] Avoid duplicate keyword variants, doorway pages, and scaled low-value content; each route must solve a different problem for the reader.

### After the first release

- [ ] Add installation, configuration, adoption, and troubleshooting documentation.
- [ ] Add library and policy-format reference pages.
- [ ] Add direct source navigation and release notes.
- [ ] Add a technical blog only when there is original implementation evidence or reproducible benchmark data to publish.
- [ ] Consider a static-site generator only when multiple routes make hand-authored HTML harder to maintain.
