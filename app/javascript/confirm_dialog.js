// Custom confirmation for Turbo (when rails-ujs confirm doesn't work)
document.addEventListener('turbo:load', function() {
  document.querySelectorAll('form[data-confirm], button[data-confirm]').forEach(function(el) {
    el.addEventListener('click', function(e) {
      var message = el.getAttribute('data-confirm');
      if (message && !window.confirm(message)) {
        e.preventDefault();
        e.stopImmediatePropagation();
        return false;
      }
    }, { capture: true });
  });
});
