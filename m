Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB066B0261
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:26:14 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id l192so260701850oih.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:26:14 -0800 (PST)
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net (p3plsmtps2ded03.prod.phx3.secureserver.net. [208.109.80.60])
        by mx.google.com with ESMTPS id i13si2694555ita.112.2016.12.13.12.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 12:26:13 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 3/5] radix tree test suite: Add new tag check
Date: Tue, 13 Dec 2016 14:21:30 -0800
Message-Id: <1481667692-14500-4-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1481667692-14500-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1481667692-14500-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Tejun Heo <tj@kernel.org>

From: Matthew Wilcox <mawilcox@microsoft.com>

We have a check that setting a tag on a single entry at root succeeds,
but we were missing a check that clearing a tag on that same entry also
succeeds.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/tag_check.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tools/testing/radix-tree/tag_check.c b/tools/testing/radix-tree/tag_check.c
index ed5f87d..fd98c13 100644
--- a/tools/testing/radix-tree/tag_check.c
+++ b/tools/testing/radix-tree/tag_check.c
@@ -324,6 +324,9 @@ static void single_check(void)
 	assert(ret == 1);
 	ret = radix_tree_gang_lookup_tag(&tree, (void **)items, 0, BATCH, 1);
 	assert(ret == 1);
+	item_tag_clear(&tree, 0, 0);
+	ret = radix_tree_gang_lookup_tag(&tree, (void **)items, 0, BATCH, 0);
+	assert(ret == 0);
 	item_kill_tree(&tree);
 }
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
