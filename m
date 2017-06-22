Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00C216B02FD
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:40:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 48so1184480qts.7
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:40:03 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id h8si55422qtc.332.2017.06.21.18.40.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 18:40:02 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id o21so354012qtb.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:40:02 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v3 05/23] powerpc: capture the PTE format changes in the dump pte report
Date: Wed, 21 Jun 2017 18:39:21 -0700
Message-Id: <1498095579-6790-6-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
References: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

The H_PAGE_F_SECOND,H_PAGE_F_GIX are not in the 64K main-PTE.
capture these changes in the dump pte report.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/mm/dump_linuxpagetables.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/dump_linuxpagetables.c b/arch/powerpc/mm/dump_linuxpagetables.c
index 44fe483..5627edd 100644
--- a/arch/powerpc/mm/dump_linuxpagetables.c
+++ b/arch/powerpc/mm/dump_linuxpagetables.c
@@ -213,7 +213,7 @@ struct flag_info {
 		.val	= H_PAGE_4K_PFN,
 		.set	= "4K_pfn",
 	}, {
-#endif
+#else /* CONFIG_PPC_64K_PAGES */
 		.mask	= H_PAGE_F_GIX,
 		.val	= H_PAGE_F_GIX,
 		.set	= "f_gix",
@@ -224,6 +224,7 @@ struct flag_info {
 		.val	= H_PAGE_F_SECOND,
 		.set	= "f_second",
 	}, {
+#endif /* CONFIG_PPC_64K_PAGES */
 #endif
 		.mask	= _PAGE_SPECIAL,
 		.val	= _PAGE_SPECIAL,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
