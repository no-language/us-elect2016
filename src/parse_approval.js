// Parse the raw approval JSON from the Roper Center to make it
// easier to deal with in R. The original file is large and contains
// nested objects, making it a pain to deal with in R, but trivially
// easy once pre-parsed in JS.
var fs = require('fs');

var filename = '../data/approval/approval_raw.json';
var approval = JSON.parse(fs.readFileSync(filename, 'utf8'));

function parse_president(pres_obj) {
  return pres_obj.ratings.map(obs => {
    return {
      name: pres_obj.fullname,
      poll_start: obs.pollingStart,
      poll_end: obs.pollingEnd,
      approve: obs.approve,
      disapprove: obs.disapprove,
      no_opinion: obs.noOpinion,
      n_obs: obs.sampleSize
    };
  });
}

let approval_parsed = approval.reduce((out, pres_obj) => {
  return out.concat(parse_president(pres_obj));
}, []);

fs.writeFileSync('../data/approval/approval_parsed.json',
                 JSON.stringify(approval_parsed));
