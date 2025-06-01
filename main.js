// Jednoduchá funkce sčítání
function add(a, b) {
  return a + b;
}

// Export pro testy
if (typeof module !== 'undefined' && typeof module.exports !== 'undefined') {
  module.exports = { add };
}

// DOM manipulace pouze pokud běží v prohlížeči
if (typeof window !== 'undefined') {
  window.addEventListener('DOMContentLoaded', () => {
    const resultElem = document.getElementById('result');
    if (resultElem) {
      const sum = add(3, 4);
      resultElem.textContent = sum;
    }
  });
}
