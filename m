Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13F006B0069
	for <linux-mm@kvack.org>; Sun, 21 Aug 2016 23:00:43 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so189933497pac.3
        for <linux-mm@kvack.org>; Sun, 21 Aug 2016 20:00:43 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id b2si20126476pfg.14.2016.08.21.20.00.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 21 Aug 2016 20:00:42 -0700 (PDT)
From: Xie Yisheng <xieyisheng1@huawei.com>
Subject: [RFC PATCH v2 2/2] arm64 Kconfig: Select gigantic page
Date: Mon, 22 Aug 2016 10:56:43 +0800
Message-ID: <1471834603-27053-3-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1471834603-27053-1-git-send-email-xieyisheng1@huawei.com>
References: <1471834603-27053-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, mhocko@suse.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Arm64 supports gigantic page after
commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
however, it got broken by 
commit 944d9fec8d7a ("hugetlb: add support for gigantic page
allocation at runtime")

This patch selects ARCH_HAS_GIGANTIC_PAGE to make this
function can be used again.

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
