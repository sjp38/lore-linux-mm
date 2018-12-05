Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 596B96B754C
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:42:06 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id r82so12783430oie.14
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:42:06 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y8si11921497otb.143.2018.12.05.08.42.05
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 08:42:05 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V4 3/6] arm64: mm: Define arch_get_mmap_end, arch_get_mmap_base
Date: Wed,  5 Dec 2018 16:41:42 +0000
Message-Id: <20181205164145.24568-4-steve.capper@arm.com>
In-Reply-To: <20181205164145.24568-1-steve.capper@arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com, Steve Capper <steve.capper@arm.com>

Now that we have DEFAULT_MAP_WINDOW defined, we can arch_get_mmap_end
and arch_get_mmap_base helpers to allow for high addresses in mmap.

Signed-off-by: Steve Capper <steve.capper@arm.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/include/asm/processor.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index 50586ca6bacb..fe95fd8b065e 100644
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
2.19.2
