Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 425786B0073
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 20:39:56 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so149216038pdj.0
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 17:39:56 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id lz6si31888103pdb.199.2015.06.22.17.39.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2015 17:39:55 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v5 PATCH 9/9] mm: madvise allow remove operation for hugetlbfs
Date: Mon, 22 Jun 2015 17:38:39 -0700
Message-Id: <1435019919-29225-10-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com>
References: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

Now that we have hole punching support for hugetlbfs, we can
also support the MADV_REMOVE interface to it.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index d215ea9..3c1b7f0 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -467,7 +467,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 
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
