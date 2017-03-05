Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB23A6B0038
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 08:20:05 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n127so206454497qkf.3
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 05:20:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w51si13462775qta.3.2017.03.05.05.20.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Mar 2017 05:20:05 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/1] mm: fix mapping_set_error call in me_pagecache_dirty
Date: Sun,  5 Mar 2017 08:20:02 -0500
Message-Id: <20170305132002.5582-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

The error code should be negative. Since this ends up in the default
case anyway, this is harmless, but it's less confusing to negate it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 mm/memory-failure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index f283c7e0a2a3..f6512c953f9b 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -673,7 +673,7 @@ static int me_pagecache_dirty(struct page *p, unsigned long pfn)
 		 * the first EIO, but we're not worse than other parts
 		 * of the kernel.
 		 */
-		mapping_set_error(mapping, EIO);
+		mapping_set_error(mapping, -EIO);
 	}
 
 	return me_pagecache_clean(p, pfn);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
