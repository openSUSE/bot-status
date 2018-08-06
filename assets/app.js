function fromNow() {
  $('.from-now').each(function () {
    var date = $(this);
    date.text(moment(date.text() * 1000).fromNow());
  });
 }
