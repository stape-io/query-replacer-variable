/// <reference path="./server-gtm-sandboxed-apis.d.ts" />

const getEventData = require('getEventData');
const decodeUriComponent = require('decodeUriComponent');
const encodeUriComponent = require('encodeUriComponent');
const parseUrl = require('parseUrl');
const makeTableMap = require('makeTableMap');
const getType = require('getType');

/*==============================================================================
==============================================================================*/

const pageLocation = getEventData('page_location');
const parsedUrl = parseUrl(pageLocation);

if (!parsedUrl.search) return pageLocation;

const fromTo = makeTableMap(data.customParams, 'from', 'to');
const searchParams = parsedUrl.searchParams;
const newSearchParams = [];

// 'fromKey' is always decoded.
for (const fromKey in searchParams) {
  const value = searchParams[fromKey];

  let toKey = decodeUriComponent(fromTo[fromKey] || fromTo[enc(fromKey)] || ''); // If the person added it either decoded or encoded.
  if (data.skipExisting && searchParams.hasOwnProperty(toKey)) toKey = undefined;

  const newKey = toKey ? toKey : fromKey;

  getType(value) === 'array' // For parameters that are repeated.
    ? value.forEach((v) => newSearchParams.push(enc(newKey) + '=' + enc(v)))
    : newSearchParams.push(enc(newKey) + '=' + enc(value));
}

return (
  parsedUrl.origin +
  parsedUrl.pathname +
  '?' +
  newSearchParams.join('&') +
  (parsedUrl.hash ? parsedUrl.hash : '')
);

/*==============================================================================
  Helpers
==============================================================================*/

function enc(data) {
  return encodeUriComponent(data || '');
}
