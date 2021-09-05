$(() => {
    $.ajax(
        "/versions.json", {
            success: res => {
                res.reverse();
                var parent_tag = $("#btn-document > .i-drop-pop");
                var children = parent_tag.children("a");
                var done = [];

                var last = null;
                for (i = 0; i < children.length; i++) {
                    for (j = 0; j < res.length; j++) {
                        var tag = res[j].replace("shardingsphere-doc-", "")
                        if( done.includes(tag) ) {
                            continue
                        }
                        if (! children[i].href.includes(tag)) {
                            done.push(tag)
                            var new_node = $('<a class="i-drop-list" href="/document/' + tag + '/en/overview"  target="_blank">' + tag + '</a>)');
                            if (last == null) {
                                parent_tag.prepend(new_node);
                                last = new_node
                            } else {
                                last.after(new_node);
                                last = new_node;
                            }
                        } else {
                            last = children[i];
                        }
                    }
                }
            },
        }
    )
})

