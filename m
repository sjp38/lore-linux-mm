Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 266336B000E
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:12:06 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id d21so11400520pll.12
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:12:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a61-v6si1177979plc.593.2018.02.14.12.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 12:12:05 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 7/8] Convert vhost to kvzalloc_struct
Date: Wed, 14 Feb 2018 12:11:53 -0800
Message-Id: <20180214201154.10186-8-willy@infradead.org>
In-Reply-To: <20180214201154.10186-1-willy@infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Joe Perches <joe@perches.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/vhost/vhost.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 1b3e8d2d5c8b..fa6c8fa80dd1 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1284,7 +1284,7 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 		return -EOPNOTSUPP;
 	if (mem.nregions > max_mem_regions)
 		return -E2BIG;
-	newmem = kvzalloc(size + mem.nregions * sizeof(*m->regions), GFP_KERNEL);
+	newmem = kvzalloc_struct(newmem, regions, mem.nregions, GFP_KERNEL);
 	if (!newmem)
 		return -ENOMEM;
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
