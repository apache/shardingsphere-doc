/*
Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements. See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
// Queue calls until the asynchronously loaded Kapa SDK is ready.
if (!window.Kapa) {
  const kapa = function () { kapa.c(arguments); };
  kapa.q = [];
  kapa.c = (args) => kapa.q.push(args);
  window.Kapa = kapa;
}

// Keep the existing AI shortcut; Hextra search remains available via / and its button.
window.addEventListener('keydown', (event) => {
  if (event.key !== 'k' || !(event.metaKey || event.ctrlKey)) return;
  event.preventDefault();
  event.stopImmediatePropagation();
  const openKapa = () => window.Kapa('open');
  const search = document.getElementById('hextra-search-dialog');
  if (search && search.open) {
    search.addEventListener('close', openKapa, { once: true });
    search.querySelector('[data-search-close]').click();
  } else {
    openKapa();
  }
}, true);
