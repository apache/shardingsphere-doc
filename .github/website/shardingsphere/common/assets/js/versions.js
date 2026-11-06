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
document.addEventListener('DOMContentLoaded', () => {
  const targets = JSON.parse(document.getElementById('doc-version-targets').textContent);
  const links = Array.from(document.querySelectorAll('a[href$="#doc-version"]'), (link) => [
    link, targets[decodeURI(link.getAttribute('href').split('#')[0])]
  ]);
  const updateLinks = () => links.forEach(([link, target]) => {
    link.href = target.url + (target.samePage ? window.location.hash : '');
  });
  updateLinks();
  window.addEventListener('hashchange', updateLinks);
});
