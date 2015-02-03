Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4C11E900016
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:43:42 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so99005992pad.1
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:43:42 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ht1si3308698pac.134.2015.02.03.09.43.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Feb 2015 09:43:36 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ7000SRIRCR350@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Feb 2015 17:47:36 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v11 06/19] mm: slub: introduce virt_to_obj function.
Date: Tue, 03 Feb 2015 20:42:59 +0300
Message-id: <1422985392-28652-7-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

virt_to_obj takes kmem_cache address, address of slab page,
address x pointing somewhere inside slab object,
and returns address of the beginning of object.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 include/linux/slub_def.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 9abf04e..db7d5de 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -110,4 +110,20 @@ static inline void sysfs_slab_remove(struct kmem_cache *s)
 }
 #endif
 
+
+/**
+ * virt_to_obj - returns address of the beginning of object.
+ * @s: object's kmem_cache
+ * @slab_page: address of slab page
+ * @x: address within object memory range
+ *
+ * Returns address of the beginning of object
+ */
+static inline void *virt_to_obj(struct kmem_cache *s,
+				const void *slab_page,
+				const void *x)
+{
+	return (void *)x - ((x - slab_page) % s->size);
+}
+
 #endif /* _LINUX_SLUB_DEF_H */
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
