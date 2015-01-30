Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id EFB9682925
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:44:13 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so53066740pab.12
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:44:13 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id dj8si5768751pdb.236.2015.01.30.06.44.03
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:44:03 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 04/19] frv: mark PUD and PMD folded
Date: Fri, 30 Jan 2015 16:43:13 +0200
Message-Id: <1422629008-13689-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Howells <dhowells@redhat.com>

Core mm expects __PAGETABLE_{PUD,PMD}_FOLDED to be defined if these page
table levels folded.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Howells <dhowells@redhat.com>
---
 arch/frv/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/frv/include/asm/pgtable.h b/arch/frv/include/asm/pgtable.h
index 93bcf2abd1a1..07d7a7ef8bd5 100644
--- a/arch/frv/include/asm/pgtable.h
+++ b/arch/frv/include/asm/pgtable.h
@@ -123,12 +123,14 @@ extern unsigned long empty_zero_page;
 #define PGDIR_MASK		(~(PGDIR_SIZE - 1))
 #define PTRS_PER_PGD		64
 
+#define __PAGETABLE_PUD_FOLDED
 #define PUD_SHIFT		26
 #define PTRS_PER_PUD		1
 #define PUD_SIZE		(1UL << PUD_SHIFT)
 #define PUD_MASK		(~(PUD_SIZE - 1))
 #define PUE_SIZE		256
 
+#define __PAGETABLE_PMD_FOLDED
 #define PMD_SHIFT		26
 #define PMD_SIZE		(1UL << PMD_SHIFT)
 #define PMD_MASK		(~(PMD_SIZE - 1))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
