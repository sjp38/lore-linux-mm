Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8B863828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 13:36:08 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id yy13so35151375pab.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 10:36:08 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id lz11si4056808pab.29.2016.02.18.10.36.04
        for <linux-mm@kvack.org>;
        Thu, 18 Feb 2016 10:36:04 -0800 (PST)
Subject: [PATCH] um, pkeys: give UML an arch_vma_access_permitted()
From: Dave Hansen <dave@sr71.net>
Date: Thu, 18 Feb 2016 10:35:57 -0800
Message-Id: <20160218183557.AE1DB383@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

UML has a special mmu_context.h and needs updates whenever the generic one
is updated.  The original pkeys patches missed this.  This fixes it up.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/um/include/asm/mmu_context.h |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff -puN arch/um/include/asm/mmu_context.h~pkeys-fix-um-arch_vma_access_permitted arch/um/include/asm/mmu_context.h
--- a/arch/um/include/asm/mmu_context.h~pkeys-fix-um-arch_vma_access_permitted	2016-02-18 10:19:17.675287570 -0800
+++ b/arch/um/include/asm/mmu_context.h	2016-02-18 10:20:09.214627363 -0800
@@ -27,6 +27,20 @@ static inline void arch_bprm_mm_init(str
 				     struct vm_area_struct *vma)
 {
 }
+
+static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
+		bool write, bool execute, bool foreign)
+{
+	/* by default, allow everything */
+	return true;
+}
+
+static inline bool arch_pte_access_permitted(pte_t pte, bool write)
+{
+	/* by default, allow everything */
+	return true;
+}
+
 /*
  * end asm-generic/mm_hooks.h functions
  */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
