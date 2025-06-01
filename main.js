// Jednoduchá funkce sčítání
function add(a, b) {
  return a + b;
}

// Export pro testy
if (typeof module !== 'undefined') {
  module.exports = { add };
}

// Po načtení DOM vypíšeme výsledek
window.addEventListener('DOMContentLoaded', () => {
  const resultElem = document.getElementById('result');
  const sum = add(3, 4);
  resultElem.textContent = sum;
});
