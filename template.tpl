___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Query Replacer",
  "description": "Replace query parameters in the page location.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "LABEL",
    "name": "label",
    "displayName": "Specify below which parameters in the \u0027page_location\u0027 Event Data variable should be replaced."
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "customParams",
    "displayName": "",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "replace this",
        "name": "from",
        "type": "TEXT",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "isUnique": true
      },
      {
        "defaultValue": "",
        "displayName": "with this",
        "name": "to",
        "type": "TEXT",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      }
    ],
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "moreSettingsGroup",
    "displayName": "More Settings",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "skipExisting",
        "checkboxText": "Skip Existing Query Parameters",
        "simpleValueType": true,
        "help": "If the URL already contains a parameter matching one from the \"\u003ci\u003ewith this\u003c/i\u003e\" column, the parameter specified in the \"\u003ci\u003ereplace this\u003c/i\u003e\" will not be replaced."
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

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


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "page_location"
              }
            ]
          }
        },
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: URL without parameters
  code: |-
    const decodeUriComponent = require('decodeUriComponent');

    const mockData = {
      customParams: [
        { from: 'this', to: 'that' },
        { from: 'foo', to: 'bar' },
      ]
    };

    mock('getEventData', (key) => {
      if (key === 'page_location') return page_location_without_query_params;
    });

    const variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo(page_location_without_query_params);
- name: URL with parameters and no modifications
  code: |-
    const decodeUriComponent = require('decodeUriComponent');

    const mockData = {
      customParams: [
        { from: 'this', to: 'that' },
        { from: 'foo', to: 'bar' },
      ]
    };

    mock('getEventData', (key) => {
      if (key === 'page_location') return page_location_with_query_params;
    });

    const variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo('https://example.com/path/?oneparam=1%202%203%204&teste=123&anotherparam=hahsdhasd&anotherparam=repeated&par%C3%A2metro=%C3%A7%C3%A3o%3F1J23I12I3J#hash');
- name: URL with parameters and no modifications (skipping existing query parameters)
  code: |-
    const decodeUriComponent = require('decodeUriComponent');

    const mockData = {
      customParams: [
        { from: 'this', to: 'that' },
        { from: 'foo', to: 'bar' },
      ],
      skipExisting: true
    };

    mock('getEventData', (key) => {
      if (key === 'page_location') return page_location_with_query_params;
    });

    const variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo('https://example.com/path/?oneparam=1%202%203%204&teste=123&anotherparam=hahsdhasd&anotherparam=repeated&par%C3%A2metro=%C3%A7%C3%A3o%3F1J23I12I3J#hash');
- name: URL with parameters and with modifications
  code: |
    const decodeUriComponent = require('decodeUriComponent');

    const mockData = {
      customParams: [
        { from: 'oneparam', to: 'new_one_param' },
        { from: 'teste', to: 'new_teste' },
        { from: 'par%C3%A2metro', to: 'testão' },
      ]
    };

    mock('getEventData', (key) => {
      if (key === 'page_location') return page_location_with_query_params;
    });

    const variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo('https://example.com/path/?new_one_param=1%202%203%204&new_teste=123&anotherparam=hahsdhasd&anotherparam=repeated&test%C3%A3o=%C3%A7%C3%A3o%3F1J23I12I3J#hash');
- name: URL with parameters and with modifications (skipping existing query parameters)
  code: |
    const decodeUriComponent = require('decodeUriComponent');

    const mockData = {
      customParams: [
        { from: 'oneparam', to: 'anotherparam' },
        { from: 'teste', to: 'new_teste' }
      ],
      skipExisting: true
    };

    mock('getEventData', (key) => {
      if (key === 'page_location') return page_location_with_query_params;
    });

    const variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo('https://example.com/path/?oneparam=1%202%203%204&new_teste=123&anotherparam=hahsdhasd&anotherparam=repeated&par%C3%A2metro=%C3%A7%C3%A3o%3F1J23I12I3J#hash');
setup: |-
  const page_location_without_query_params = 'https://example.com/path/#hash';
  const page_location_with_query_params = 'https://example.com/path/?oneparam=1%202%203%204&teste=123&anotherparam=hahsdhasd&par%C3%A2metro=%C3%A7%C3%A3o%3F1J23I12I3J&anotherparam=repeated#hash';


___NOTES___

Created on 26/11/2024, 13:54:56


