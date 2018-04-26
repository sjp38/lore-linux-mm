Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 201946B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 11:10:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v2so4339183wmh.2
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 08:10:24 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id x47si2132842edd.301.2018.04.26.07.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 07:28:51 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 2/9] arm: mm: migrate: add pmd swap entry to support thp migration.
Date: Thu, 26 Apr 2018 10:27:57 -0400
Message-Id: <20180426142804.180152-3-zi.yan@sent.com>
In-Reply-To: <20180426142804.180152-1-zi.yan@sent.com>
References: <20180426142804.180152-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Russell King <linux@armlinux.org.uk>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org

From: Zi Yan <zi.yan@cs.rutgers.edu>

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Christoffer Dall <christoffer.dall@linaro.org>
Cc: Marc Zyngier <marc.zyngier@arm.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-mm@kvack.org
---
 arch/arm/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index a757401129f9..d4b35514e96a 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -347,7 +347,9 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 #define __swp_entry(type,offset) ((swp_entry_t) { ((type) << __SWP_TYPE_SHIFT) | ((offset) << __SWP_OFFSET_SHIFT) })
 
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
+#define __pmd_to_swp_entry(pmd)	((swp_entry_t) { pmd_val(pmd) })
 #define __swp_entry_to_pte(swp)	((pte_t) { (swp).val })
+#define __swp_entry_to_pmd(swp)	((pmd_t) { (swp).val })
 
 /*
  * It is an error for the kernel to have more swap files than we can
-- 
2.17.0
