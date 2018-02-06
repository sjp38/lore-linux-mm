Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C28A26B02A5
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 17:10:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r82so1567432wme.0
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 14:10:07 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id i67si256515wmi.233.2018.02.06.14.10.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Feb 2018 14:10:06 -0800 (PST)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mm/ksm: make function stable_node_dup static
Date: Tue,  6 Feb 2018 22:10:05 +0000
Message-Id: <20180206221005.12642-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The function stable_node_dup is local to the source and does not need
to be in global scope, so make it static.

Cleans up sparse warning:
mm/ksm.c:1321:13: warning: symbol 'stable_node_dup' was not
declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/ksm.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 293721f5da70..30ebdbfaf373 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1318,10 +1318,10 @@ bool is_page_sharing_candidate(struct stable_node *stable_node)
 	return __is_page_sharing_candidate(stable_node, 0);
 }
 
-struct page *stable_node_dup(struct stable_node **_stable_node_dup,
-			     struct stable_node **_stable_node,
-			     struct rb_root *root,
-			     bool prune_stale_stable_nodes)
+static struct page *stable_node_dup(struct stable_node **_stable_node_dup,
+				    struct stable_node **_stable_node,
+				    struct rb_root *root,
+				    bool prune_stale_stable_nodes)
 {
 	struct stable_node *dup, *found = NULL, *stable_node = *_stable_node;
 	struct hlist_node *hlist_safe;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
