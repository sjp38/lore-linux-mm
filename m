Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DC339828F3
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:54 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so53157127pad.7
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:54 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id oh8si1543211pdb.40.2015.01.30.06.43.50
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:50 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 09/19] mn10300: mark PUD and PMD folded
Date: Fri, 30 Jan 2015 16:43:18 +0200
Message-Id: <1422629008-13689-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>

Core mm expects __PAGETABLE_{PUD,PMD}_FOLDED to be defined if these page
table levels folded.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
---
 arch/mn10300/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/mn10300/include/asm/pgtable.h b/arch/mn10300/include/asm/pgtable.h
index afab728ab65e..96d3f9deb59c 100644
--- a/arch/mn10300/include/asm/pgtable.h
+++ b/arch/mn10300/include/asm/pgtable.h
@@ -56,7 +56,9 @@ extern void paging_init(void);
 #define PGDIR_SHIFT	22
 #define PTRS_PER_PGD	1024
 #define PTRS_PER_PUD	1	/* we don't really have any PUD physically */
+#define __PAGETABLE_PUD_FOLDED
 #define PTRS_PER_PMD	1	/* we don't really have any PMD physically */
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PTE	1024
 
 #define PGD_SIZE	PAGE_SIZE
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
