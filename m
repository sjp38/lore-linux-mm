Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7066B02E8
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 15:07:54 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id k19so259315553iod.4
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 12:07:54 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id 13si5983657itw.88.2016.11.28.12.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 12:07:53 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 14/33] radix-tree: Fix typo
Date: Mon, 28 Nov 2016 13:50:18 -0800
Message-Id: <1480369871-5271-15-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

---
 lib/radix-tree.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e0290d1..b329056 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1109,7 +1109,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 	 * because RADIX_TREE_MAP_SHIFT < BITS_PER_LONG.
 	 *
 	 * This condition also used by radix_tree_next_slot() to stop
-	 * contiguous iterating, and forbid swithing to the next chunk.
+	 * contiguous iterating, and forbid switching to the next chunk.
 	 */
 	index = iter->next_index;
 	if (!index && iter->index)
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
