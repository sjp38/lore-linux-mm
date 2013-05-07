Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id CB8F36B00CF
	for <linux-mm@kvack.org>; Tue,  7 May 2013 16:49:32 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id q57so1077337wes.9
        for <linux-mm@kvack.org>; Tue, 07 May 2013 13:49:31 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 1/3] mm: honor FOLL_GET flag in follow_hugetlb_page
Date: Tue,  7 May 2013 16:45:54 -0400
Message-Id: <1367959554-3218-1-git-send-email-j.glisse@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>

From: Jerome Glisse <jglisse@redhat.com>

Do not increase page count if FOLL_GET is not set.

Signed-off-by: Jerome Glisse <jglisse@redhat.com>
---
 mm/hugetlb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1a12f5b..5d1e46b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2991,7 +2991,9 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 same_page:
 		if (pages) {
 			pages[i] = mem_map_offset(page, pfn_offset);
-			get_page(pages[i]);
+			if (flags & FOLL_GET) {
+				get_page_foll(pages[i]);
+			}
 		}
 
 		if (vmas)
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
