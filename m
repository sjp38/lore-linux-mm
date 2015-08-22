Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 150AA6B0038
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 03:44:09 -0400 (EDT)
Received: by ykll84 with SMTP id l84so91803593ykl.0
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 00:44:08 -0700 (PDT)
Received: from m12-11.163.com (m12-11.163.com. [220.181.12.11])
        by mx.google.com with ESMTP id s48si17617230qgd.111.2015.08.22.00.43.37
        for <linux-mm@kvack.org>;
        Sat, 22 Aug 2015 00:44:08 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 3/3] mm/memblock: fix memblock comment
Date: Sat, 22 Aug 2015 15:40:12 +0800
Message-Id: <1440229212-8737-3-git-send-email-bywxiaobai@163.com>
In-Reply-To: <1440229212-8737-1-git-send-email-bywxiaobai@163.com>
References: <1440229212-8737-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

's/amd/and/'

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/memblock.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index cc4b019..273aad7 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -304,7 +304,7 @@ static inline void __init memblock_set_bottom_up(bool enable) {}
 static inline bool memblock_bottom_up(void) { return false; }
 #endif
 
-/* Flags for memblock_alloc_base() amd __memblock_alloc_base() */
+/* Flags for memblock_alloc_base() and __memblock_alloc_base() */
 #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
 #define MEMBLOCK_ALLOC_ACCESSIBLE	0
 
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
