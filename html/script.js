let players = [];
let reports = [];
let selectedPlayer = null;

window.addEventListener('message', function(event) {
    console.log('[DEBUG][NUI] Otrzymano message:', event.data);
    if (event.data.type === 'openTablet') {
        console.log('[DEBUG][NUI] Otwieranie tabletu:', event.data);
        showTablet();
        players = event.data.players;
        reports = event.data.reports;
        renderPlayers();
        renderReports();
        document.getElementById('sentence-section').style.display = 'none';
    }
    if (event.data.type === 'sentences') {
        console.log('[DEBUG][NUI] renderSentenceHistory', event.data.sentences);
        renderSentenceHistory(event.data.sentences || []);
    } else if (event.data.type !== 'openTablet' && event.data.type !== 'closeTablet') {
        console.log('[DEBUG][NUI] message NIE JEST typu sentences:', event.data.type);
    }
    if (event.data.type === 'closeTablet') {
        console.log('[DEBUG][NUI] Zamykanie tabletu:', event.data);
        hideTablet();
    }
});


function hideTablet() {
    document.getElementById('tablet-frame').style.display = 'none';
}
function showTablet() {
    document.getElementById('tablet-frame').style.display = 'flex';
}
hideTablet();

function renderPlayers() {
    const ul = document.getElementById('players-list');
    ul.innerHTML = '';
    players.forEach(player => {
        const li = document.createElement('li');
        let statusSpan = document.createElement('span');
        if (player.wanted) {
            statusSpan.textContent = `POSZUKIWANY: ${player.wanted}`;
            statusSpan.className = 'status-poszukiwany';
            li.classList.add('poszukiwany');
        } else {
            statusSpan.textContent = 'NIE POSZUKIWANY';
            statusSpan.className = 'status-nieposzukiwany';
        }
        li.innerHTML = `${player.id} | ${player.name} [`;
        li.appendChild(statusSpan);
        li.innerHTML += "]";
        li.style.cursor = 'pointer';
        li.onclick = () => selectPlayer(player);
        ul.appendChild(li);
    });
}

function renderReports() {
    const ul = document.getElementById('reports-list');
    ul.innerHTML = '';
    reports.forEach(report => {
        const li = document.createElement('li');
        li.textContent = `${report.id} | ${report.text}`;
        ul.appendChild(li);
    });
}

function selectPlayer(player) {
    selectedPlayer = player;
    document.getElementById('selected-player').textContent = `${player.id} | ${player.name}`;
    document.getElementById('sentence-section').style.display = 'block';
    showTab('akcje');

    let statusDiv = document.getElementById('player-status');
    if (!statusDiv) {
        statusDiv = document.createElement('div');
        statusDiv.id = 'player-status';
        document.getElementById('sentence-section').insertBefore(statusDiv, document.getElementById('tab-akcje-content'));
    }
    if (player.wanted) {
        statusDiv.innerHTML = `<span class="status-poszukiwany">Status: POSZUKIWANY: ${player.wanted}</span>`;
    } else {
        statusDiv.innerHTML = `<span class="status-nieposzukiwany">Status: NIE POSZUKIWANY</span>`;
    }
    // Pobierz WSZYSTKIE wyroki
    $.post(`https://${GetParentResourceName()}/getSentences`, JSON.stringify({}));
}

function showTab(tab) {
    document.getElementById('tab-akcje-content').style.display = tab === 'akcje' ? 'block' : 'none';
    document.getElementById('tab-wyrok-content').style.display = tab === 'wyrok' ? 'block' : 'none';
    document.getElementById('tab-historia-content').style.display = tab === 'historia' ? 'block' : 'none';
    document.getElementById('tab-akcje').classList.toggle('active', tab === 'akcje');
    document.getElementById('tab-wyrok').classList.toggle('active', tab === 'wyrok');
    if(document.getElementById('tab-historia'))
        document.getElementById('tab-historia').classList.toggle('active', tab === 'historia');
    if(tab === 'historia') {
        $.post(`https://${GetParentResourceName()}/getSentences`, JSON.stringify({}));
    }
}



const sentenceForm = document.getElementById('sentence-form');
sentenceForm.addEventListener('submit', function(e) {
    e.preventDefault();
    if (!selectedPlayer) return;
    const data = {
        imie: document.getElementById('sentence-imie').value,
        nazwisko: document.getElementById('sentence-nazwisko').value,
        powod: document.getElementById('sentence-powod').value,
        data: document.getElementById('sentence-data').value,
        tresc: document.getElementById('sentence-tresc').value
    };
    $.post(`https://${GetParentResourceName()}/saveSentence`, JSON.stringify({ player: selectedPlayer, sentence: data }));
    sentenceForm.reset();
    setTimeout(() => {
        // Odśwież WSZYSTKIE wyroki
        $.post(`https://${GetParentResourceName()}/getSentences`, JSON.stringify({}));
    }, 500);
});

function renderSentenceHistory(list) {
    const ul = document.getElementById('sentence-history');
    ul.innerHTML = '';
    if (!list || list.length === 0) {
        const li = document.createElement('li');
        li.textContent = 'Brak wyroków';
        ul.appendChild(li);
        return;
    }
    list.forEach((item, idx) => {
        const li = document.createElement('li');
        li.innerHTML = `<b>ID: ${item.id}</b> | <b>${item.imie || ''} ${item.nazwisko || ''}</b> | <i>${item.powod || ''}</i> | <b>${item.data || ''}</b><br>${item.tresc || ''}`;
        ul.appendChild(li);
    });
}

document.getElementById('send-sentence').onclick = function() {
    const sentence = document.getElementById('sentence-input').value;
    if (selectedPlayer && sentence) {
        fetch(`https://${GetParentResourceName()}/sendSentence`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ player: selectedPlayer, sentence })
        });
        document.getElementById('sentence-input').value = '';
        document.getElementById('sentence-section').style.display = 'none';
    }
};

document.getElementById('set-wanted').onclick = function() {
    const reason = document.getElementById('wanted-reason').value;
    if (selectedPlayer && reason) {
        fetch(`https://${GetParentResourceName()}/setWanted`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ player: selectedPlayer, reason })
        });
        document.getElementById('wanted-reason').value = '';
        document.getElementById('sentence-section').style.display = 'none';
    }
};

document.getElementById('pardon').onclick = function() {
    if (selectedPlayer) {
        fetch(`https://${GetParentResourceName()}/pardonPlayer`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ player: selectedPlayer })
        });
        document.getElementById('sentence-section').style.display = 'none';
    }
};

document.getElementById('back').onclick = function() {
    document.getElementById('sentence-section').style.display = 'none';
};

document.getElementById('close-btn').onclick = function() {
    fetch(`https://${GetParentResourceName()}/closeTablet`, { method: 'POST' });
};

document.onkeydown = function(e) {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeTablet`, { method: 'POST' });
    }
};
