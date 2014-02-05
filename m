Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A9EAA6B003B
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 19:02:39 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so8950796pde.0
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 16:02:39 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id a6si26563838pao.70.2014.02.04.16.02.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Feb 2014 16:02:38 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv2 1/2] mm/memblock: add memblock_get_current_limit
Date: Tue,  4 Feb 2014 16:02:30 -0800
Message-Id: <1391558551-31395-2-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1391558551-31395-1-git-send-email-lauraa@codeaurora.org>
References: <1391558551-31395-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

Appart from setting the limit of memblock, it's also useful to be able
to get the limit to avoid recalculating it every time. Add the function
to do so.

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
index 87d21a6..3820e29 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1404,6 +1404,11 @@ void __init_memblock memblock_set_current_limit(phys_addr_t limit)
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
