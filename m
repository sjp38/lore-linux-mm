Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 687E16B0034
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 11:02:11 -0400 (EDT)
Date: Tue, 13 Aug 2013 08:01:36 -0700
From: tip-bot for Jianguo Wu <tipbot@zytor.com>
Message-ID: <tip-d4f5228c01c130ff2c1f9240f1de22a5dfc61554@git.kernel.org>
Reply-To: mingo@kernel.org, hpa@zytor.com, linux-kernel@vger.kernel.org,
        wangchen@cn.fujitsu.com, wujianguo@huawei.com, tglx@linutronix.de,
        iamjoonsoo.kim@lge.com, guohanjun@huawei.com, linux-mm@kvack.org
In-Reply-To: <5209A173.3090600@huawei.com>
References: <5209A173.3090600@huawei.com>
Subject: [tip:x86/mm] mm: Remove unused variable idx0 in __early_ioremap()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@kernel.org, wangchen@cn.fujitsu.com, wujianguo@huawei.com, tglx@linutronix.de, iamjoonsoo.kim@lge.com, guohanjun@huawei.com, linux-mm@kvack.org

Commit-ID:  d4f5228c01c130ff2c1f9240f1de22a5dfc61554
Gitweb:     http://git.kernel.org/tip/d4f5228c01c130ff2c1f9240f1de22a5dfc61554
Author:     Jianguo Wu <wujianguo@huawei.com>
AuthorDate: Tue, 13 Aug 2013 11:01:07 +0800
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Tue, 13 Aug 2013 11:46:36 +0200

mm: Remove unused variable idx0 in __early_ioremap()

After commit:

   8827247ffcc ("x86: don't define __this_fixmap_does_not_exist()")

variable idx0 is no longer needed, so just remove it.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: <linux-mm@kvack.org>
Cc: <wangchen@cn.fujitsu.com>
Cc: Hanjun Guo <guohanjun@huawei.com>
Link: http://lkml.kernel.org/r/5209A173.3090600@huawei.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/ioremap.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 0215e2c..799580c 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -487,7 +487,7 @@ __early_ioremap(resource_size_t phys_addr, unsigned long size, pgprot_t prot)
 	unsigned long offset;
 	resource_size_t last_addr;
 	unsigned int nrpages;
-	enum fixed_addresses idx0, idx;
+	enum fixed_addresses idx;
 	int i, slot;
 
 	WARN_ON(system_state != SYSTEM_BOOTING);
@@ -540,8 +540,7 @@ __early_ioremap(resource_size_t phys_addr, unsigned long size, pgprot_t prot)
 	/*
 	 * Ok, go for it..
 	 */
-	idx0 = FIX_BTMAP_BEGIN - NR_FIX_BTMAPS*slot;
-	idx = idx0;
+	idx = FIX_BTMAP_BEGIN - NR_FIX_BTMAPS*slot;
 	while (nrpages > 0) {
 		early_set_fixmap(idx, phys_addr, prot);
 		phys_addr += PAGE_SIZE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
