Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id EFDFD900015
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 10:12:33 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so40104013pab.3
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 07:12:33 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id bx10si10326923pdb.37.2015.01.29.07.12.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 29 Jan 2015 07:12:29 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIY00K4N2FNL610@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Jan 2015 15:16:35 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v10 04/17] mm: slub: introduce virt_to_obj function.
Date: Thu, 29 Jan 2015 18:11:48 +0300
Message-id: <1422544321-24232-5-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

virt_to_obj takes kmem_cache address, address of slab page,
address x pointing somewhere inside slab object,
and returns address of the begging of object.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 include/linux/slub_def.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 9abf04e..eca3883 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -110,4 +110,9 @@ static inline void sysfs_slab_remove(struct kmem_cache *s)
 }
 #endif
 
+static inline void *virt_to_obj(struct kmem_cache *s, void *slab_page, void *x)
+{
+	return x - ((x - slab_page) % s->size);
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
