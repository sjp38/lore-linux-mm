Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DCDDF6B003C
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:37 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so9094950pab.2
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:37 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id bl10si8124661pad.194.2014.07.09.04.36.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:36 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G0035708QSY60@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:26 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 09/21] mm: Makefile: kasan: don't instrument
 slub.c and slab_common.c files
Date: Wed, 09 Jul 2014 15:30:03 +0400
Message-id: <1404905415-9046-10-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

Code in slub.c and slab_common.c files could validly access to object's
redzones

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/Makefile | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/Makefile b/mm/Makefile
index 6a9c3f8..59cc184 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -3,6 +3,8 @@
 #
 
 KASAN_SANITIZE_page_alloc.o := n
+KASAN_SANITIZE_slab_common.o := n
+KASAN_SANITIZE_slub.o := n
 
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= gup.o highmem.o madvise.o memory.o mincore.o \
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
