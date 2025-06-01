const { add } = require('../main');

test('add 1 + 2 should equal 3', () => {
  expect(add(1, 2)).toBe(3);
});

test('add -5 + 5 should equal 0', () => {
  expect(add(-5, 5)).toBe(0);
});
