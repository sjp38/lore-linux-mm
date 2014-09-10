Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5478D6B003B
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:38:36 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so11317188pde.19
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:38:36 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ba9si12734453pdb.146.2014.09.10.07.38.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 10 Sep 2014 07:38:35 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBO005M4WSYAY90@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 10 Sep 2014 15:41:22 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH v2 04/10] mm: slub: introduce virt_to_obj function.
Date: Wed, 10 Sep 2014 18:31:21 +0400
Message-id: <1410359487-31938-5-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

virt_to_obj takes kmem_cache address, address of slab page,
address x pointing somewhere inside slab object,
and returns address of the begging of object.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/slab.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/slab.h b/mm/slab.h
index 026e7c3..3e3a6ae 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -346,4 +346,10 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
 
+static inline void *virt_to_obj(struct kmem_cache *s, void *slab_page, void *x)
+{
+	return x - ((x - slab_page) % s->size);
+}
+
+
 #endif /* MM_SLAB_H */
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
