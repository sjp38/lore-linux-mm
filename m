Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9FE6B0038
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 07:51:24 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so5672723pad.39
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 04:51:23 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id du3si4745870pdb.374.2014.08.01.04.51.23
        for <linux-mm@kvack.org>;
        Fri, 01 Aug 2014 04:51:23 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: mark fault_around_bytes __read_mostly
Date: Fri,  1 Aug 2014 14:51:09 +0300
Message-Id: <1406893869-32739-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1406893869-32739-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1406893869-32739-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

fault_around_bytes can only be changed via debugfs. Let's mark it
read-mostly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Suggested-by: David Rientjes <rientjes@google.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/memory.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index be43fd9606db..281556eb4e62 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2768,7 +2768,8 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
-static unsigned long fault_around_bytes = rounddown_pow_of_two(65536);
+static unsigned long fault_around_bytes __read_mostly =
+	rounddown_pow_of_two(65536);
 
 #ifdef CONFIG_DEBUG_FS
 static int fault_around_bytes_get(void *data, u64 *val)
-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
