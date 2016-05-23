Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF3C6B025F
	for <linux-mm@kvack.org>; Mon, 23 May 2016 13:14:46 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id rs7so67801751lbb.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:14:46 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id c143si17416332wmh.66.2016.05.23.10.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 10:14:42 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id f75so10745345wmf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:14:42 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH 1/3] mm, thp: remove duplication of included header
Date: Mon, 23 May 2016 20:14:09 +0300
Message-Id: <1464023651-19420-2-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

swapops.h included for a second time in the commit:
http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=639040960a340f6f987065fc52e149f4ea25ce25

This patch removes the duplication.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
 mm/huge_memory.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9472fed..91442a9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -30,7 +30,6 @@
 #include <linux/hashtable.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/page_idle.h>
-#include <linux/swapops.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
