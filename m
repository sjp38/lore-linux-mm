Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 385816B0071
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 19:03:30 -0400 (EDT)
Received: by obfe9 with SMTP id e9so54249817obf.1
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 16:03:30 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id zc2si6497803obc.86.2015.04.16.16.03.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 16:03:29 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 4/4] mm: madvise allow remove operation for hugetlbfs
Date: Thu, 16 Apr 2015 16:02:58 -0700
Message-Id: <1429225378-22965-5-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1429225378-22965-1-git-send-email-mike.kravetz@oracle.com>
References: <1429225378-22965-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>

Now that we have hole punching support for hugetlbfs, we can
also support the MADV_REMOVE interface to it.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index d551475..c4a1027 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -299,7 +299,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 
 	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
 
-	if (vma->vm_flags & (VM_LOCKED | VM_HUGETLB))
+	if (vma->vm_flags & VM_LOCKED)
 		return -EINVAL;
 
 	f = vma->vm_file;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
