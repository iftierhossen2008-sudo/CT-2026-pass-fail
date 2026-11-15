<!DOCTYPE html>
<html lang="bn">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>সিটি পরীক্ষা: পাস নাকি ফেল?</title>
<style>
  * { box-sizing: border-box; }
  body { font-family: 'Segoe UI', Tahoma, sans-serif; background: linear-gradient(135deg, #1e1b4b, #4c1d95); color: #fff; margin: 0; padding: 20px; min-height: 100vh; }
  h1 { text-align: center; margin-bottom: 4px; }
  .note { text-align: center; color: #fde68a; margin-bottom: 20px; font-size: 14px; }
  .top { max-width: 800px; margin: 0 auto 20px; text-align: center; }
  .counter { margin: 10px 0; font-size: 18px; }
  .pass-c { color: #4ade80; font-weight: bold; }
  .fail-c { color: #f87171; font-weight: bold; }
  button { background: #f59e0b; color: #1e1b4b; border: none; padding: 10px 18px; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; margin: 4px; }
  button:hover { background: #fbbf24; }
  button:disabled { opacity: 0.5; cursor: not-allowed; }
  .reset { background: #94a3b8; }
  table { width: 100%; max-width: 800px; margin: 0 auto; border-collapse: collapse; background: rgba(255,255,255,0.08); border-radius: 12px; overflow: hidden; }
  th, td { padding: 12px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.15); }
  th { background: rgba(0,0,0,0.3); }
  .result { font-weight: bold; font-size: 18px; min-width: 110px; }
  .pass { color: #4ade80; }
  .fail { color: #f87171; }
  .spinning { color: #fde68a; animation: blink 0.2s infinite; }
  @keyframes blink { 50% { opacity: 0.4; } }
</style>
</head>
<body>
  <h1>🎡 সিটি পরীক্ষা: পাস নাকি ফেল?</h1>
  <div class="note">⚠️ এটা শুধুই মজার জন্য, আসল রেজাল্টের সাথে এর কোনো সম্পর্ক নেই!</div>

  <div class="top">
    <div class="counter">পাস: <span class="pass-c" id="passCount">0</span> | ফেল: <span class="fail-c" id="failCount">0</span> | বাকি: <span id="leftCount">0</span></div>
    <button id="spinAll">🎲 সবাইকে একসাথে স্পিন করো</button>
    <button class="reset" id="resetBtn">🔄 রিসেট</button>
  </div>

  <table>
    <thead><tr><th>নং</th><th>নাম</th><th>রেজাল্ট</th><th>স্পিন</th></tr></thead>
    <tbody id="tbody"></tbody>
  </table>

<script>
  // ডেমো নাম: এখানে ৬৩ জনের আসল নাম বসিয়ে দাও
  const names = [];
  for (let i = 1; i <= 63; i++) names.push('ছাত্র ' + i);

  const results = new Array(names.length).fill(null);
  const tbody = document.getElementById('tbody');

  names.forEach((name, i) => {
    const tr = document.createElement('tr');
    tr.innerHTML = `<td>${i + 1}</td><td>${name}</td><td class="result" id="r${i}">—</td><td><button id="b${i}">স্পিন</button></td>`;
    tbody.appendChild(tr);
    document.getElementById('b' + i).addEventListener('click', () => spin(i));
  });

  function spin(i) {
    return new Promise(resolve => {
      const cell = document.getElementById('r' + i);
      const btn = document.getElementById('b' + i);
      btn.disabled = true;
      cell.className = 'result spinning';
      let count = 0;
      const timer = setInterval(() => {
        cell.textContent = Math.random() < 0.5 ? 'পাস' : 'ফেল';
        count++;
        if (count > 15) {
          clearInterval(timer);
          const isPass = Math.random() < 0.5;
          results[i] = isPass;
          cell.textContent = isPass ? '✅ পাস' : '❌ ফেল';
          cell.className = 'result ' + (isPass ? 'pass' : 'fail');
          btn.disabled = false;
          updateCounts();
          resolve();
        }
      }, 80);
    });
  }

  function updateCounts() {
    const p = results.filter(r => r === true).length;
    const f = results.filter(r => r === false).length;
    document.getElementById('passCount').textContent = p;
    document.getElementById('failCount').textContent = f;
    document.getElementById('leftCount').textContent = names.length - p - f;
  }

  document.getElementById('spinAll').addEventListener('click', async () => {
    const btn = document.getElementById('spinAll');
    btn.disabled = true;
    await Promise.all(names.map((_, i) => spin(i)));
    btn.disabled = false;
  });

  document.getElementById('resetBtn').addEventListener('click', () => {
    names.forEach((_, i) => {
      results[i] = null;
      const cell = document.getElementById('r' + i);
      cell.textContent = '—';
      cell.className = 'result';
    });
    updateCounts();
  });

  updateCounts();
</script>
</body>
</html>
