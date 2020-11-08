const showAllLoans =
  'data:image/png;base64,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';

const newDoc = 'https://img.icons8.com/pastel-glyph/2x/check-document.png';

const verify =
  'data:image/png;base64,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';

const auction = 'https://webstockreview.net/images/auction-clipart.jpg';
// const auctionURL = require('./images/auction.jpg');
// const auction = `url(${auctionURL})`;

const newLoan =
  'https://www.searchpng.com/wp-content/uploads/2019/02/Saving-Icon-715x715.png';
const profile =
  'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSDGQO5-8CPA9Hzl5_wLkAf6VtlMw52q7IwRw&usqp=CAU';

module.exports = { showAllLoans, newDoc, newLoan, profile, verify, auction };