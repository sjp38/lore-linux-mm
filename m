Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 721966B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 08:33:17 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id d49so749931eek.6
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 05:33:16 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id f2si13469096eeo.238.2014.01.16.05.33.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 05:33:16 -0800 (PST)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Thu, 16 Jan 2014 13:33:16 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3E8EA17D8058
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:33:22 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0GDWu1C63766762
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:32:56 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0GDX8m9000557
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 06:33:08 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH] mm/nobootmem: Fix unused variable
Date: Thu, 16 Jan 2014 14:33:06 +0100
Message-Id: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Philipp Hachtmann <phacht@linux.vnet.ibm.com>

This fixes an unused variable warning in nobootmem.c

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 mm/nobootmem.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index e2906a5..12cbb04 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -116,9 +116,13 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
 static unsigned long __init free_low_memory_core_early(void)
 {
 	unsigned long count = 0;
-	phys_addr_t start, end, size;
+	phys_addr_t start, end;
 	u64 i;
 
+#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+	phys_addr_t size;
+#endif
+
 	for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
 		count += __free_memory_core(start, end);
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
