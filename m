Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 037B46B0253
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:30:28 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id y67so43648425oig.3
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:30:27 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id a61si12936472otc.190.2016.09.30.02.30.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Sep 2016 02:30:22 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v4 2/2] arm64 Kconfig: Select gigantic page
Date: Fri, 30 Sep 2016 17:26:09 +0800
Message-ID: <1475227569-63446-3-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1475227569-63446-1-git-send-email-xieyisheng1@huawei.com>
References: <1475227569-63446-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Arm64 supports gigantic page after
commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
however, it can only be allocated at boottime and can't be freed.

This patch selects ARCH_HAS_GIGANTIC_PAGE to make gigantic pages
can be allocated and freed at runtime for arch arm64.

Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 arch/arm64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index bc3f00f..92217f6 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -9,6 +9,7 @@ config ARM64
 	select ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_GCOV_PROFILE_ALL
+	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_SG_CHAIN
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
