/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

document.addEventListener('DOMContentLoaded', () => {
  function tokenize(text) {
    var regex = /::=|\?|\*|\+|\||\(|\)|\[|\]|'[^']*'|[A-Za-z_][A-Za-z0-9_-]*|,/g;
    var tokens = text.match(regex);
    return tokens ? tokens : [];
  }

  function parseExpression(tokens, indexRef) {
    var terms = [parseTerm(tokens, indexRef)];
    while (tokens[indexRef.idx] === '|') {
      indexRef.idx += 1;
      terms.push(parseTerm(tokens, indexRef));
    }
    if (terms.length === 1) {
      return terms[0];
    }
    return { type: 'choice', options: terms };
  }

  function parseTerm(tokens, indexRef) {
    var items = [];
    while (indexRef.idx < tokens.length) {
      var tok = tokens[indexRef.idx];
      if (tok === '|' || tok === ')' || tok === ']') {
        break;
      }
      items.push(parseFactor(tokens, indexRef));
    }
    if (items.length === 1) {
      return items[0];
    }
    return { type: 'sequence', items: items };
  }

  function parseFactor(tokens, indexRef) {
    var node = parsePrimary(tokens, indexRef);
    var tok = tokens[indexRef.idx];
    if (tok === '?' || tok === '*' || tok === '+') {
      indexRef.idx += 1;
      if (tok === '?') {
        node = { type: 'optional', item: node };
      } else if (tok === '*') {
        node = { type: 'zeroOrMore', item: node };
      } else if (tok === '+') {
        node = { type: 'oneOrMore', item: node };
      }
    }
    return node;
  }

  function parsePrimary(tokens, indexRef) {
    var tok = tokens[indexRef.idx];
    indexRef.idx += 1;
    if (!tok) {
      return { type: 'terminal', value: '' };
    }
    if (tok === '(') {
      var expr = parseExpression(tokens, indexRef);
      indexRef.idx += 1; // skip ')'
      return expr;
    }
    if (tok === '[') {
      var optExpr = parseExpression(tokens, indexRef);
      indexRef.idx += 1; // skip ']'
      return { type: 'optional', item: optExpr };
    }
    if (tok[0] === "'" && tok.length >= 2) {
      return { type: 'terminal', value: tok.slice(1, -1) };
    }
    return { type: 'nonterminal', value: tok };
  }

  function astToRailroad(node) {
    switch (node.type) {
      case 'terminal':
        return new Terminal(node.value);
      case 'nonterminal':
        return new NonTerminal(node.value);
      case 'sequence':
        return Sequence.apply(null, node.items.map(astToRailroad));
      case 'choice':
        var opts = node.options.map(astToRailroad);
        return Choice.apply(null, [0].concat(opts));
      case 'optional':
        return new Optional(astToRailroad(node.item), 'skip');
      case 'zeroOrMore':
        return new ZeroOrMore(astToRailroad(node.item));
      case 'oneOrMore':
        return new OneOrMore(astToRailroad(node.item));
      default:
        return new Terminal('');
    }
  }

  function parseDefinitions(text) {
    var blocks = text.split(/\n\s*\n/);
    var defs = [];
    for (var i = 0; i < blocks.length; i++) {
      var block = blocks[i].trim();
      if (!block) {
        continue;
      }
      var parts = block.split('::=');
      if (parts.length < 2) {
        continue;
      }
      var name = parts[0].trim().split(/\s+/)[0];
      var rhs = parts.slice(1).join('::=').trim();
      defs.push({ name: name, rhs: rhs });
    }
    return defs;
  }

  function renderRailroad(grammar) {
    var defs = parseDefinitions(grammar);
    var htmlParts = [];
    for (var i = 0; i < defs.length; i++) {
      var def = defs[i];
      try {
        var tokens = tokenize(def.rhs);
        var ast = parseExpression(tokens, { idx: 0 });
        // Diagram takes items as varargs; call as a factory to wrap arguments correctly
        var diagram = Diagram(astToRailroad(ast));
        htmlParts.push('<p class=\"rr-title\">' + def.name + ':</p>');
        htmlParts.push('<div class=\"rr-wrapper\">' + diagram.toString() + '</div>');
      } catch (e) {
        htmlParts.push('<p class=\"rr-title\">' + def.name + ':</p><p>Railroad diagram unavailable.</p>');
      }
    }
    return htmlParts.join('\n');
  }

  document.querySelectorAll('iframe#diagram').forEach(frame => {
    const panels = frame.closest('.hextra-tabs-panel').parentElement;
    const grammar = panels.querySelector('code').textContent.trim();
    const container = document.createElement('div');
    container.className = 'railroad-diagrams';
    container.innerHTML = renderRailroad(grammar);
    frame.replaceWith(container);
  });
});
