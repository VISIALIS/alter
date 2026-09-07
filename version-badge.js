(function () {
    var CACHE_KEY = 'alter-latest-version';
    var CACHE_TTL_MS = 6 * 60 * 60 * 1000; // 6h : évite de re-fetcher à chaque visite

    function render(version) {
        var text = 'v' + version;
        document.querySelectorAll('[data-alter-version]').forEach(function (el) {
            el.textContent = text;
        });

        // Mise à jour dynamique des liens de téléchargement
        document.querySelectorAll('[data-alter-download-pattern]').forEach(function (el) {
            var pattern = el.getAttribute('data-alter-download-pattern');
            if (pattern) {
                var url = 'https://github.com/VISIALIS/alter/releases/download/v' + version + '/' + pattern.replace('{{VERSION}}', version);
                el.setAttribute('href', url);
            }
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

    function highlightCurrentOS() {
        var plat = (navigator.userAgentData && navigator.userAgentData.platform) || navigator.platform || navigator.userAgent || '';
        plat = plat.toLowerCase();
        var osName = null;
        if (plat.indexOf('win') !== -1) osName = 'windows';
        else if (plat.indexOf('mac') !== -1 && !('ontouchend' in document) && !/iphone|ipad|ipod/.test((navigator.userAgent || '').toLowerCase())) osName = 'macos';
        else if (plat.indexOf('linux') !== -1 || plat.indexOf('x11') !== -1) osName = 'linux';

        if (!osName) return;
        document.querySelectorAll('.download-platform-row').forEach(function (row) {
            var platSpan = row.querySelector('.platform');
            var label = (platSpan ? platSpan.textContent : '').toLowerCase().trim();
            if (label.indexOf(osName) !== -1 || (osName === 'macos' && label === 'macos') || (osName === 'windows' && label === 'windows') || (osName === 'linux' && label === 'linux')) {
                row.classList.add('detected-os-row');
                if (platSpan && !platSpan.querySelector('.download-recommended-badge')) {
                    var b = document.createElement('span');
                    b.className = 'download-recommended-badge';
                    b.textContent = 'Detected';
                    platSpan.appendChild(b);
                }
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', highlightCurrentOS);
    } else {
        highlightCurrentOS();
    }
})();
