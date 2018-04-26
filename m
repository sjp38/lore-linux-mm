Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF166B000A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:28:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m69so4283659wma.0
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:28:53 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id j8si5780366edj.26.2018.04.26.07.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 07:28:51 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 1/9] arc: mm: migrate: add pmd swap entry to support thp migration.
Date: Thu, 26 Apr 2018 10:27:56 -0400
Message-Id: <20180426142804.180152-2-zi.yan@sent.com>
In-Reply-To: <20180426142804.180152-1-zi.yan@sent.com>
References: <20180426142804.180152-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Vineet Gupta <vgupta@synopsys.com>, linux-snps-arc@lists.infradead.org

From: Zi Yan <zi.yan@cs.rutgers.edu>

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: linux-snps-arc@lists.infradead.org
Cc: linux-mm@kvack.org
---
 arch/arc/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 08fe33830d4b..246934105e61 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -383,7 +383,9 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
 
 /* NOPs, to keep generic kernel happy */
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
+#define __pmd_to_swp_entry(pmd)	((swp_entry_t) { pmd_val(pmd) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
+#define __swp_entry_to_pmd(x)	((pmd_t) { (x).val })
 
 #define kern_addr_valid(addr)	(1)
 
-- 
2.17.0
