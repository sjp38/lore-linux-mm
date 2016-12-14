Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7EE6B0253
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:12:19 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id bk3so4798158wjc.4
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:12:19 -0800 (PST)
Received: from mail-wj0-x236.google.com (mail-wj0-x236.google.com. [2a00:1450:400c:c01::236])
        by mx.google.com with ESMTPS id w65si6336641wmf.6.2016.12.14.01.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 01:12:18 -0800 (PST)
Received: by mail-wj0-x236.google.com with SMTP id v7so22166058wjy.2
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:12:18 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Date: Wed, 14 Dec 2016 09:11:47 +0000
Message-Id: <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: catalin.marinas@arm.com, akpm@linux-foundation.org, hanjun.guo@linaro.org, xieyisheng1@huawei.com, rrichter@cavium.com, james.morse@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

The NUMA code may get confused by the presence of NOMAP regions within
zones, resulting in spurious BUG() checks where the node id deviates
from the containing zone's node id.

Since the kernel has no business reasoning about node ids of pages it
does not own in the first place, enable CONFIG_HOLES_IN_ZONE to ensure
that such pages are disregarded.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 111742126897..0472afe64d55 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -614,6 +614,10 @@ config NEED_PER_CPU_EMBED_FIRST_CHUNK
 	def_bool y
 	depends on NUMA
 
+config HOLES_IN_ZONE
+	def_bool y
+	depends on NUMA
+
 source kernel/Kconfig.preempt
 source kernel/Kconfig.hz
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
