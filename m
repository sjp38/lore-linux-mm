Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9B56B0253
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 09:48:39 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i88so188392156pfk.3
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 06:48:39 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id t1si15366495pge.38.2016.12.18.06.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 06:48:38 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id b1so5511895pgc.1
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 06:48:38 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH V2 1/2] mm/memblock.c: trivial code refine in memblock_is_region_memory()
Date: Sun, 18 Dec 2016 14:47:49 +0000
Message-Id: <1482072470-26151-2-git-send-email-richard.weiyang@gmail.com>
In-Reply-To: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

The base address is already guaranteed to be in the region by
memblock_search().

This patch removes the check on base.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 7608bc3..cd85303 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1615,7 +1615,7 @@ int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size
 
 	if (idx == -1)
 		return 0;
-	return memblock.memory.regions[idx].base <= base &&
+	return /* memblock.memory.regions[idx].base <= base && */
 		(memblock.memory.regions[idx].base +
 		 memblock.memory.regions[idx].size) >= end;
 }
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
