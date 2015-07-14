Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id E799D280250
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:28:23 -0400 (EDT)
Received: by igvi1 with SMTP id i1so63912532igv.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:28:23 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id g80si1873840ioe.85.2015.07.14.14.28.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 14:28:23 -0700 (PDT)
Received: by igbij6 with SMTP id ij6so56775207igb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:28:23 -0700 (PDT)
Date: Tue, 14 Jul 2015 14:28:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: improve __GFP_NORETRY comment based on implementation
Message-ID: <alpine.DEB.2.10.1507141426410.16182@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>

Explicitly state that __GFP_NORETRY will attempt direct reclaim and memory 
compaction before returning NULL and that the oom killer is not called in 
the current implementation of the page allocator.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/gfp.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -63,7 +63,10 @@ struct vm_area_struct;
  * but it is definitely preferable to use the flag rather than opencode endless
  * loop around allocator.
  *
- * __GFP_NORETRY: The VM implementation must not retry indefinitely.
+ * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
+ * return NULL when direct reclaim and memory compaction has failed to allow the
+ * allocation to succeed.  The OOM killer is not called with the current
+ * implementation.
  *
  * __GFP_MOVABLE: Flag that this page will be movable by the page migration
  * mechanism or reclaimed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
