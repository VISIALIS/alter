(function () {
    var CACHE_KEY = 'alter-latest-version';
    var CACHE_TTL_MS = 6 * 60 * 60 * 1000; // 6h : évite de re-fetcher à chaque visite

    function render(version) {
        var text = 'v' + version;
        document.querySelectorAll('[data-alter-version]').forEach(function (el) {
            el.textContent = text;
        });
    }

    function fromCache() {
        try {
            var raw = localStorage.getItem(CACHE_KEY);
            if (!raw) return null;
            var cached = JSON.parse(raw);
            if (Date.now() - cached.at > CACHE_TTL_MS) return null;
            return cached.version;
        } catch (e) {
            return null;
        }
    }

    function toCache(version) {
        try {
            localStorage.setItem(CACHE_KEY, JSON.stringify({ version: version, at: Date.now() }));
        } catch (e) {
            // localStorage indisponible (mode privé strict, quota) : pas bloquant
        }
    }

    var cached = fromCache();
    if (cached) {
        render(cached);
        return;
    }

    fetch('https://api.github.com/repos/VISIALIS/alter/releases/latest', {
        headers: { Accept: 'application/vnd.github+json' },
    })
        .then(function (res) {
            if (!res.ok) throw new Error('GitHub API status ' + res.status);
            return res.json();
        })
        .then(function (data) {
            var tag = data && data.tag_name;
            if (!tag) return;
            var version = tag.replace(/^v/, '');
            toCache(version);
            render(version);
        })
        .catch(function () {
            // Rate limit anonyme atteint, offline, etc. : les badges gardent
            // leur texte de repli statique (voir markup), pas d'erreur visible.
        });
})();
