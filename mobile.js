(() => {
  const frame = document.getElementById('gameFrame');
  const joystick = document.getElementById('joystick');
  const stick = document.getElementById('stick');
  const controls = document.getElementById('mobileControls');
  const message = document.getElementById('screenMessage');
  const pressed = new Set();
  let joyPointer = null;

  function gameWindow() {
    try { return frame.contentWindow; } catch (_) { return null; }
  }
  function sendKey(key, down) {
    const target = gameWindow();
    if (!target) return;
    const keyName = key === ' ' ? ' ' : key;
    const code = keyName === ' ' ? 'Space' : keyName.length === 1 ? 'Key' + keyName.toUpperCase() : keyName;
    const event = new KeyboardEvent(down ? 'keydown' : 'keyup', {
      key: keyName, code, bubbles: true, cancelable: true
    });
    try {
      target.dispatchEvent(event);
      target.document.dispatchEvent(new KeyboardEvent(event.type, {
        key: keyName, code, bubbles: true, cancelable: true
      }));
    } catch (_) {
      message.hidden = false;
    }
  }
  function setKey(key, down) {
    if (down && !pressed.has(key)) { pressed.add(key); sendKey(key, true); }
    if (!down && pressed.has(key)) { pressed.delete(key); sendKey(key, false); }
  }
  function releaseAll() {
    [...pressed].forEach(key => setKey(key, false));
  }
  window.addEventListener('blur', releaseAll);
  document.addEventListener('visibilitychange', () => { if (document.hidden) releaseAll(); });
  frame.addEventListener('load', () => { message.hidden = true; releaseAll(); });
  frame.addEventListener('error', () => { message.hidden = false; });

  function moveJoystick(event) {
    const rect = joystick.getBoundingClientRect();
    const cx = rect.left + rect.width / 2;
    const cy = rect.top + rect.height / 2;
    const max = rect.width * .29;
    let dx = event.clientX - cx, dy = event.clientY - cy;
    const length = Math.hypot(dx, dy);
    if (length > max) { dx = dx / length * max; dy = dy / length * max; }
    stick.style.left = (50 + dx / rect.width * 100) + '%';
    stick.style.top = (50 + dy / rect.height * 100) + '%';
    const dead = rect.width * .13;
    setKey('a', dx < -dead); setKey('d', dx > dead);
    setKey('w', dy < -dead); setKey('s', dy > dead);
  }
  function resetJoystick() {
    joyPointer = null;
    stick.style.left = '50%'; stick.style.top = '50%';
    ['w','a','s','d'].forEach(key => setKey(key, false));
  }
  joystick.addEventListener('pointerdown', event => {
    event.preventDefault(); joyPointer = event.pointerId;
    joystick.setPointerCapture(event.pointerId); moveJoystick(event);
  });
  joystick.addEventListener('pointermove', event => {
    if (event.pointerId === joyPointer) { event.preventDefault(); moveJoystick(event); }
  });
  joystick.addEventListener('pointerup', event => { if (event.pointerId === joyPointer) resetJoystick(); });
  joystick.addEventListener('pointercancel', resetJoystick);

  document.querySelectorAll('[data-key]').forEach(button => {
    const key = button.dataset.key;
    button.addEventListener('pointerdown', event => {
      event.preventDefault(); button.setPointerCapture(event.pointerId);
      button.classList.add('pressed'); setKey(key, true);
    });
    const up = event => {
      if (event) event.preventDefault();
      button.classList.remove('pressed'); setKey(key, false);
    };
    button.addEventListener('pointerup', up);
    button.addEventListener('pointercancel', up);
    button.addEventListener('lostpointercapture', up);
    button.addEventListener('contextmenu', event => event.preventDefault());
  });

  document.getElementById('controlsToggle').addEventListener('click', () => {
    controls.classList.toggle('hidden');
    document.getElementById('controlsToggle').textContent = controls.classList.contains('hidden') ? 'Show controls' : 'Hide controls';
  });
  document.getElementById('loadGame').addEventListener('click', () => {
    const url = document.getElementById('gameUrl').value.trim();
    if (!url) return;
    try { frame.src = new URL(url, location.href).href; message.hidden = false; }
    catch (_) { message.hidden = false; }
  });
  document.getElementById('gameUrl').addEventListener('keydown', event => {
    if (event.key === 'Enter') document.getElementById('loadGame').click();
  });
  window.addEventListener('pagehide', releaseAll);
})();