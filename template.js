/// <reference path="./server-gtm-sandboxed-apis.d.ts" />

const getEventData = require('getEventData');
const decodeUriComponent = require('decodeUriComponent');
const encodeUriComponent = require('encodeUriComponent');
const parseUrl = require('parseUrl');
const makeTableMap = require('makeTableMap');

/*==============================================================================
==============================================================================*/

const pageLocation = getEventData('page_location');
const parsedUrl = parseUrl(pageLocation);

if (!parsedUrl.search) return pageLocation;

const fromTo = makeTableMap(data.customParams, 'from', 'to');
const searchParams = parsedUrl.searchParams;
const newSearchParams = [];

// 'key' is always decoded.
for (let key in searchParams) {
  const value = searchParams[key];
  const newKey = decodeUriComponent(fromTo[key] || fromTo[encodeUriComponent(key)] || ''); // If the person added it either decoded or encoded.
  newSearchParams.push(encodeUriComponent(newKey ? newKey : key) + '=' + encodeUriComponent(value));
}

return (
  parsedUrl.origin +
  parsedUrl.pathname +
  '?' +
  newSearchParams.join('&') +
  (parsedUrl.hash ? parsedUrl.hash : '')
);
