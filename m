Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id F3A426B02B0
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 17:01:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id x190so27219825qkb.5
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 14:01:10 -0700 (PDT)
Received: from mail-qt0-f170.google.com (mail-qt0-f170.google.com. [209.85.216.170])
        by mx.google.com with ESMTPS id u58si2174939qtu.58.2016.11.02.14.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 14:01:10 -0700 (PDT)
Received: by mail-qt0-f170.google.com with SMTP id n6so16745906qtd.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 14:01:10 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv2 5/6] arm64: Use __pa_symbol for _end
Date: Wed,  2 Nov 2016 15:00:53 -0600
Message-Id: <20161102210054.16621-6-labbott@redhat.com>
In-Reply-To: <20161102210054.16621-1-labbott@redhat.com>
References: <20161102210054.16621-1-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org


__pa_symbol is technically the marco that should be used for kernel
symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 arch/arm64/mm/init.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 212c4d1..3236eb0 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -209,8 +209,8 @@ void __init arm64_memblock_init(void)
 	 * linear mapping. Take care not to clip the kernel which may be
 	 * high in memory.
 	 */
-	memblock_remove(max_t(u64, memstart_addr + linear_region_size, __pa(_end)),
-			ULLONG_MAX);
+	memblock_remove(max_t(u64, memstart_addr + linear_region_size,
+			__pa_symbol(_end)), ULLONG_MAX);
 	if (memstart_addr + linear_region_size < memblock_end_of_DRAM()) {
 		/* ensure that memstart_addr remains sufficiently aligned */
 		memstart_addr = round_up(memblock_end_of_DRAM() - linear_region_size,
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
