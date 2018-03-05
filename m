Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5906B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:07:52 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o23so11970192wrc.9
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:07:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v29sor6493296wra.31.2018.03.05.12.07.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:07:51 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 01/25] slab: fixup calculate_alignment() argument type
Date: Mon,  5 Mar 2018 23:07:06 +0300
Message-Id: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index a1237d38a27e..7626a64b8f14 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -280,7 +280,7 @@ static inline void memcg_unlink_cache(struct kmem_cache *s)
  * Figure out what the alignment of the objects will be given a set of
  * flags, a user specified alignment and the size of the objects.
  */
-static unsigned long calculate_alignment(unsigned long flags,
+static unsigned long calculate_alignment(slab_flags_t flags,
 		unsigned long align, unsigned long size)
 {
 	/*
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
