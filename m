Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 317066B000C
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:28:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c56-v6so27178041wrc.5
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:28:54 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id i3si2459812eds.215.2018.04.26.07.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 07:28:52 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 5/9] mips: mm: migrate: add pmd swap entry to support thp migration.
Date: Thu, 26 Apr 2018 10:28:00 -0400
Message-Id: <20180426142804.180152-6-zi.yan@sent.com>
In-Reply-To: <20180426142804.180152-1-zi.yan@sent.com>
References: <20180426142804.180152-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mips@linux-mips.org

From: Zi Yan <zi.yan@cs.rutgers.edu>

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: James Hogan <jhogan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mips@linux-mips.org
Cc: linux-mm@kvack.org
---
 arch/mips/include/asm/pgtable-64.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/mips/include/asm/pgtable-64.h b/arch/mips/include/asm/pgtable-64.h
index 0036ea0c7173..ec72e5b12965 100644
--- a/arch/mips/include/asm/pgtable-64.h
+++ b/arch/mips/include/asm/pgtable-64.h
@@ -366,6 +366,8 @@ static inline pte_t mk_swap_pte(unsigned long type, unsigned long offset)
 #define __swp_offset(x)		((x).val >> 24)
 #define __swp_entry(type, offset) ((swp_entry_t) { pte_val(mk_swap_pte((type), (offset))) })
 #define __pte_to_swp_entry(pte) ((swp_entry_t) { pte_val(pte) })
+#define __pmd_to_swp_entry(pmd) ((swp_entry_t) { pmd_val(pmd) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
+#define __swp_entry_to_pmd(x)	((pmd_t) { (x).val })
 
 #endif /* _ASM_PGTABLE_64_H */
-- 
2.17.0
