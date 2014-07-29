Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 690366B003B
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 07:33:54 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so12252056pac.32
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 04:33:54 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id py12si20888204pab.17.2014.07.29.04.33.53
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 04:33:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: mark fault_around_bytes __read_mostly
Date: Tue, 29 Jul 2014 14:33:29 +0300
Message-Id: <1406633609-17586-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1406633609-17586-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1406633609-17586-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

fault_around_bytes can only be changed via debugfs. Let's mark it
read-mostly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 2ce07dc9b52b..ed3073d6a0e0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2768,7 +2768,8 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
-static unsigned long fault_around_bytes = rounddown_pow_of_two(65536);
+static unsigned long fault_around_bytes __read_mostly =
+	rounddown_pow_of_two(65536);
 
 static inline unsigned long fault_around_pages(void)
 {
-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
