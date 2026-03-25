# minorugh.github.io

Minoru's online documents published via GitHub Pages.

https://minorugh.github.io

## Structure

```
.
├── docs/          # Site source (Jekyll)
│   ├── _config.yml
│   ├── _layouts/
│   ├── _includes/
│   ├── img/
│   └── *.md
└── makefile       # Auto deploy via cron (daily 23:50)
```

## Deploy

Committed and pushed automatically by cron every day at 23:50.
Manual deploy from `docs/`:

```bash
make
```
