Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7C24D6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:37:13 -0400 (EDT)
Received: by wiga1 with SMTP id a1so166464195wig.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 07:37:12 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id fx12si53008261wjc.192.2015.06.25.07.37.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jun 2015 07:37:12 -0700 (PDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Thu, 25 Jun 2015 15:37:10 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 605051B08023
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 15:38:13 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5PEb8GF40435744
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:37:08 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5P9UH7j014267
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 05:30:17 -0400
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH] s390/mm: change HPAGE_SHIFT type to int
Date: Thu, 25 Jun 2015 16:37:01 +0200
Message-Id: <1435243021-65315-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org

With making HPAGE_SHIFT an unsigned integer we also accidentally changed pageblock_order.
In order to avoid compiler warnings we make HPAGE_SHFIT an int again.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/include/asm/page.h | 2 +-
 arch/s390/mm/pgtable.c       | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/s390/include/asm/page.h b/arch/s390/include/asm/page.h
index 0844b78..dd34523 100644
--- a/arch/s390/include/asm/page.h
+++ b/arch/s390/include/asm/page.h
@@ -20,7 +20,7 @@
 #include <asm/setup.h>
 #ifndef __ASSEMBLY__
 
-extern unsigned int HPAGE_SHIFT;
+extern int HPAGE_SHIFT;
 #define HPAGE_SIZE	(1UL << HPAGE_SHIFT)
 #define HPAGE_MASK	(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index f76791e..1bae5dd 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -36,7 +36,7 @@
 #endif
 
 
-unsigned int HPAGE_SHIFT;
+int HPAGE_SHIFT;
 
 unsigned long *crst_table_alloc(struct mm_struct *mm)
 {
-- 
2.3.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
