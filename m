Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 376726B0309
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:35:20 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g187so71137394itc.2
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:35:20 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id x31si254938ioi.138.2016.11.16.14.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:35:19 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 13/29] radix-tree: Fix typo
Date: Wed, 16 Nov 2016 16:17:16 -0800
Message-Id: <1479341856-30320-52-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

---
 lib/radix-tree.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 6d73575..e917c56 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1147,7 +1147,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
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
