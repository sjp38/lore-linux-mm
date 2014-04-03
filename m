Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 66B926B0035
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 13:05:07 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so2039821pdj.8
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 10:05:07 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id xt7si3353126pab.266.2014.04.03.10.05.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Apr 2014 10:05:06 -0700 (PDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv5 1/2] mm/memblock: add memblock_get_current_limit
Date: Thu,  3 Apr 2014 10:04:57 -0700
Message-Id: <1396544698-15596-2-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1396544698-15596-1-git-send-email-lauraa@codeaurora.org>
References: <1396544698-15596-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

Apart from setting the limit of memblock, it's also useful to be able
to get the limit to avoid recalculating it every time. Add the function
to do so.

Change-Id: I4f28dc1e549fd4c7fabf4e0dbd97871dbaa318ab
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
Acked-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 include/linux/memblock.h | 2 ++
 mm/memblock.c            | 5 +++++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 1ef6636..8a20a51 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -252,6 +252,8 @@ static inline void memblock_dump_all(void)
 void memblock_set_current_limit(phys_addr_t limit);
 
 
+phys_addr_t memblock_get_current_limit(void);
+
 /*
  * pfn conversion functions
  *
diff --git a/mm/memblock.c b/mm/memblock.c
index 39a31e7..7fe5354 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1407,6 +1407,11 @@ void __init_memblock memblock_set_current_limit(phys_addr_t limit)
 	memblock.current_limit = limit;
 }
 
+phys_addr_t __init_memblock memblock_get_current_limit(void)
+{
+	return memblock.current_limit;
+}
+
 static void __init_memblock memblock_dump(struct memblock_type *type, char *name)
 {
 	unsigned long long base, size;
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
