Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id A734B6B0037
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 10:22:58 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id u56so5103967wes.9
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 07:22:57 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id bv14si14097805wjb.41.2014.04.22.07.22.56
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 07:22:57 -0700 (PDT)
Date: Tue, 22 Apr 2014 07:22:45 -0700
From: Drew Richardson <drew.richardson@arm.com>
Subject: [PATCH] Export kmem tracepoints for use by kernel modules
Message-ID: <20140422142244.GA21121@dreric01-Precision-T1600>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michel Lespinasse <walken@google.com>, Mikulas Patocka <mpatocka@redhat.com>, William Roberts <bill.c.roberts@gmail.com>, Gideon Israel Dsouza <gidisrael@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>

After commit de7b2973903c6cc50b31ee5682a69b2219b9919d ("tracepoint:
Use struct pointer instead of name hash for reg/unreg tracepoints"),
any tracepoints used in a kernel module must be exported.

Signed-off-by: Drew Richardson <drew.richardson@arm.com>
Acked-by: Pawel Moll <pawel.moll@arm.com>
---
 mm/util.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/util.c b/mm/util.c
index f380af7ea779..379e8db560b3 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -502,3 +502,9 @@ EXPORT_TRACEPOINT_SYMBOL(kmalloc_node);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc_node);
 EXPORT_TRACEPOINT_SYMBOL(kfree);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_free);
+EXPORT_TRACEPOINT_SYMBOL_GPL(mm_page_free);
+EXPORT_TRACEPOINT_SYMBOL_GPL(mm_page_free_batched);
+EXPORT_TRACEPOINT_SYMBOL_GPL(mm_page_alloc);
+EXPORT_TRACEPOINT_SYMBOL_GPL(mm_page_alloc_zone_locked);
+EXPORT_TRACEPOINT_SYMBOL_GPL(mm_page_pcpu_drain);
+EXPORT_TRACEPOINT_SYMBOL_GPL(mm_page_alloc_extfrag);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
