Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFACE6B025E
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 09:25:06 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id e70so320085583ioi.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 06:25:06 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id h63si10471179otb.237.2016.08.22.06.25.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 06:25:06 -0700 (PDT)
From: Xie Yisheng <xieyisheng1@huawei.com>
Subject: [RFC PATCH v3 2/2] arm64 Kconfig: Select gigantic page
Date: Mon, 22 Aug 2016 21:20:04 +0800
Message-ID: <1471872004-59365-3-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1471872004-59365-1-git-send-email-xieyisheng1@huawei.com>
References: <1471872004-59365-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, mhocko@suse.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Arm64 supports gigantic page after
commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
however, it can only be allocated at boottime and can't be freed.

This patch selects ARCH_HAS_GIGANTIC_PAGE to make gigantic pages
can be allocated and freed at runtime for arch arm64.

Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Xie Yisheng <xieyisheng1@huawei.com>
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
