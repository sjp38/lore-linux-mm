Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B868C6B0069
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:07:49 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id m4so4613121pgc.23
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:07:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c78si12456803pfe.384.2017.11.22.13.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:07:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 05/62] radix tree: Add a missing cast to gfp_t
Date: Wed, 22 Nov 2017 13:06:42 -0800
Message-Id: <20171122210739.29916-6-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

sparse complains about an invalid type assignment.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 lib/radix-tree.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index c8d55565fafa..f00303e0b216 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -178,7 +178,7 @@ static inline void root_tag_clear(struct radix_tree_root *root, unsigned tag)
 
 static inline void root_tag_clear_all(struct radix_tree_root *root)
 {
-	root->gfp_mask &= (1 << ROOT_TAG_SHIFT) - 1;
+	root->gfp_mask &= (__force gfp_t)((1 << ROOT_TAG_SHIFT) - 1);
 }
 
 static inline int root_tag_get(const struct radix_tree_root *root, unsigned tag)
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
