Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 56E566B007E
	for <linux-mm@kvack.org>; Sun,  3 Apr 2016 01:46:20 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id bc4so115084258lbc.2
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 22:46:20 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id t131si12384338lfd.163.2016.04.02.22.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Apr 2016 22:46:18 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id c126so6024407lfb.2
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 22:46:18 -0700 (PDT)
Subject: [PATCH] mm/mmap: kill hook arch_rebalance_pgtables
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sun, 03 Apr 2016 08:46:15 +0300
Message-ID: <145966237520.3981.8917077611530564532.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org

Nobody use it.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 mm/mmap.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index bd2e1a533bc1..fba246b8f1a5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -55,10 +55,6 @@
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
 
-#ifndef arch_rebalance_pgtables
-#define arch_rebalance_pgtables(addr, len)		(addr)
-#endif
-
 #ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
 const int mmap_rnd_bits_min = CONFIG_ARCH_MMAP_RND_BITS_MIN;
 const int mmap_rnd_bits_max = CONFIG_ARCH_MMAP_RND_BITS_MAX;
@@ -1911,7 +1907,6 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 	if (offset_in_page(addr))
 		return -EINVAL;
 
-	addr = arch_rebalance_pgtables(addr, len);
 	error = security_mmap_addr(addr);
 	return error ? error : addr;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
