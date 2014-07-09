Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED476B0069
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:49 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so9106962pad.37
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:49 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id cd7si45849625pad.105.2014.07.09.04.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:48 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G001G40911T60@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:37 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 18/21] arm: mm: reserve shadow memory for kasan
Date: Wed, 09 Jul 2014 15:30:12 +0400
Message-id: <1404905415-9046-19-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/arm/mm/init.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 659c75d..02fce2c 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -22,6 +22,7 @@
 #include <linux/memblock.h>
 #include <linux/dma-contiguous.h>
 #include <linux/sizes.h>
+#include <linux/kasan.h>
 
 #include <asm/cp15.h>
 #include <asm/mach-types.h>
@@ -324,6 +325,8 @@ void __init arm_memblock_init(const struct machine_desc *mdesc)
 	 */
 	dma_contiguous_reserve(min(arm_dma_limit, arm_lowmem_limit));
 
+	kasan_alloc_shadow();
+
 	arm_memblock_steal_permitted = false;
 	memblock_dump_all();
 }
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
