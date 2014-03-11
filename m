Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 76C7E6B0075
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 06:11:31 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id z10so8350134pdj.32
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 03:11:30 -0700 (PDT)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id pg1si19677434pac.299.2014.03.11.03.11.26
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 03:11:30 -0700 (PDT)
From: Dongsheng Yang <yangds.fnst@cn.fujitsu.com>
Subject: [PATCH 07/17] mm: Replace hardcoding of 19 with MAX_NICE.
Date: Tue, 11 Mar 2014 18:09:15 +0800
Message-Id: <53e301a8f762608bb85d8c9d56b85de836564349.1394532288.git.yangds.fnst@cn.fujitsu.com>
In-Reply-To: <cover.1394532288.git.yangds.fnst@cn.fujitsu.com>
References: <cover.1394532288.git.yangds.fnst@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: peterz@infradead.org, joe@perches.com, mingo@kernel.org, tglx@linutronix.de, heiko.carstens@de.ibm.com, Dongsheng Yang <yangds.fnst@cn.fujitsu.com>, linux-mm@kvack.org, Bob Liu <lliubbo@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Dongsheng Yang <yangds.fnst@cn.fujitsu.com>
cc: linux-mm@kvack.org
cc: Bob Liu <lliubbo@gmail.com>
cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
cc: Mel Gorman <mgorman@suse.de>
cc: Rik van Riel <riel@redhat.com>
cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1546655..dcdb6f9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2803,7 +2803,7 @@ static int khugepaged(void *none)
 	struct mm_slot *mm_slot;
 
 	set_freezable();
-	set_user_nice(current, 19);
+	set_user_nice(current, MAX_NICE);
 
 	while (!kthread_should_stop()) {
 		khugepaged_do_scan();
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
