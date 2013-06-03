Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 960396B0037
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 11:35:12 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bi5so398839pad.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 08:35:11 -0700 (PDT)
Message-ID: <51ACB7AA.5050705@gmail.com>
Date: Mon, 03 Jun 2013 23:35:06 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] mm, vmalloc: Remove insert_vmalloc_vm
References: <51ACB6DB.6040809@gmail.com>
In-Reply-To: <51ACB6DB.6040809@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Now this function is nowhere used, we can remove it directly.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/vmalloc.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index edbfad0..e0a786d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1322,13 +1322,6 @@ static void clear_vm_unlist(struct vm_struct *vm)
 	vm->flags &= ~VM_UNLIST;
 }
 
-static void insert_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
-			      unsigned long flags, const void *caller)
-{
-	setup_vmalloc_vm(vm, va, flags, caller);
-	clear_vm_unlist(vm);
-}
-
 static struct vm_struct *__get_vm_area_node(unsigned long size,
 		unsigned long align, unsigned long flags, unsigned long start,
 		unsigned long end, int node, gfp_t gfp_mask, const void *caller)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
