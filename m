Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 810B66B000E
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 08:39:46 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id n196so4772398oig.15
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 05:39:46 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t53si9828697oti.205.2018.11.14.05.39.45
        for <linux-mm@kvack.org>;
        Wed, 14 Nov 2018 05:39:45 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V3 3/5] arm64: mm: Define arch_get_mmap_end, arch_get_mmap_base
Date: Wed, 14 Nov 2018 13:39:18 +0000
Message-Id: <20181114133920.7134-4-steve.capper@arm.com>
In-Reply-To: <20181114133920.7134-1-steve.capper@arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com, Steve Capper <steve.capper@arm.com>

Now that we have DEFAULT_MAP_WINDOW defined, we can arch_get_mmap_end
and arch_get_mmap_base helpers to allow for high addresses in mmap.

Signed-off-by: Steve Capper <steve.capper@arm.com>
---
 arch/arm64/include/asm/processor.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index da41a2655b69..bbe602cb8fd3 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -72,6 +72,13 @@
 #define STACK_TOP		STACK_TOP_MAX
 #endif /* CONFIG_COMPAT */
 
+#define arch_get_mmap_end(addr) ((addr > DEFAULT_MAP_WINDOW) ? TASK_SIZE :\
+				DEFAULT_MAP_WINDOW)
+
+#define arch_get_mmap_base(addr, base) ((addr > DEFAULT_MAP_WINDOW) ? \
+					base + TASK_SIZE - DEFAULT_MAP_WINDOW :\
+					base)
+
 extern phys_addr_t arm64_dma_phys_limit;
 #define ARCH_LOW_ADDRESS_LIMIT	(arm64_dma_phys_limit - 1)
 
-- 
2.11.0
