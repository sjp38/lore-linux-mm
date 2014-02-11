Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E19CE6B0036
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:14:35 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so8198570pad.25
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:14:35 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id to9si20226296pbc.185.2014.02.11.13.14.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Feb 2014 13:14:35 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv3 1/2] mm/memblock: add memblock_get_current_limit
Date: Tue, 11 Feb 2014 13:14:24 -0800
Message-Id: <1392153265-14439-2-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1392153265-14439-1-git-send-email-lauraa@codeaurora.org>
References: <1392153265-14439-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

Appart from setting the limit of memblock, it's also useful to be able
to get the limit to avoid recalculating it every time. Add the function
to do so.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 include/linux/memblock.h |    2 ++
 mm/memblock.c            |    5 +++++
 2 files changed, 7 insertions(+), 0 deletions(-)

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
