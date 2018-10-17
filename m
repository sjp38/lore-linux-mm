Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id D84286B026D
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:35:30 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id u205-v6so2039596oie.5
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 09:35:30 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s83-v6si8716712oie.222.2018.10.17.09.35.29
        for <linux-mm@kvack.org>;
        Wed, 17 Oct 2018 09:35:29 -0700 (PDT)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V2 3/4] arm64: mm: Define arch_get_mmap_end, arch_get_mmap_base
Date: Wed, 17 Oct 2018 17:34:58 +0100
Message-Id: <20181017163459.20175-4-steve.capper@arm.com>
In-Reply-To: <20181017163459.20175-1-steve.capper@arm.com>
References: <20181017163459.20175-1-steve.capper@arm.com>
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
index 46c9d9ff028c..5afc0c5eb1cb 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -78,6 +78,13 @@
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
