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

The initial release is one landing page. Documentation, library reference, source navigation, and a blog may follow while preserving static output and measurable performance budgets.
