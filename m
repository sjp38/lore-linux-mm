Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 77BDA6B0035
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 21:49:03 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so2221200yhn.18
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 18:49:03 -0800 (PST)
Received: from mail-pb0-x229.google.com (mail-pb0-x229.google.com [2607:f8b0:400e:c01::229])
        by mx.google.com with ESMTPS id q66si3065582yhm.279.2013.12.08.18.49.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 08 Dec 2013 18:49:02 -0800 (PST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so4493480pbb.28
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 18:49:01 -0800 (PST)
Message-ID: <52A53024.9090701@gmail.com>
Date: Mon, 09 Dec 2013 10:51:16 +0800
From: Chen Gang <gang.chen.5i5j@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm/zswap.c: add BUG() for default case in zswap_writeback_entry()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Hogan <james.hogan@imgtec.com>

Recommend to add default case to avoid compiler's warning, although at
present, the original implementation is still correct.

The related warning (with allmodconfig for metag):

    CC      mm/zswap.o
  mm/zswap.c: In function 'zswap_writeback_entry':
  mm/zswap.c:537: warning: 'ret' may be used uninitialized in this function


Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 mm/zswap.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 5a63f78..bfd1807 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -585,6 +585,8 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 
 		/* page is up to date */
 		SetPageUptodate(page);
+	default:
+		BUG();
 	}
 
 	/* move it to the tail of the inactive list after end_writeback */
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
