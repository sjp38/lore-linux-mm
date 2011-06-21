Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 295676B0101
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 04:11:24 -0400 (EDT)
From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH 3/4] mm: improve THP printk messages
Date: Tue, 21 Jun 2011 16:10:44 +0800
Message-Id: <1308643849-3325-3-git-send-email-amwang@redhat.com>
In-Reply-To: <1308643849-3325-1-git-send-email-amwang@redhat.com>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Amerigo Wang <amwang@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

As Andrea suggested, use "THP:" prefix to avoid
being confused with hugetlb.

Signed-off-by: WANG Cong <amwang@redhat.com>
---
 mm/huge_memory.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 126c96b..f9e720c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -506,7 +506,7 @@ static int __init hugepage_init(void)
 	if (no_hugepage_init) {
 		err = 0;
 		transparent_hugepage_flags = 0;
-		printk(KERN_INFO "hugepage: totally disabled\n");
+		printk(KERN_INFO "THP: totally disabled\n");
 		goto out;
 	}
 
@@ -514,19 +514,19 @@ static int __init hugepage_init(void)
 	err = -ENOMEM;
 	hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
 	if (unlikely(!hugepage_kobj)) {
-		printk(KERN_ERR "hugepage: failed kobject create\n");
+		printk(KERN_ERR "THP: failed kobject create\n");
 		goto out;
 	}
 
 	err = sysfs_create_group(hugepage_kobj, &hugepage_attr_group);
 	if (err) {
-		printk(KERN_ERR "hugepage: failed register hugeage group\n");
+		printk(KERN_ERR "THP: failed register hugeage group\n");
 		goto out;
 	}
 
 	err = sysfs_create_group(hugepage_kobj, &khugepaged_attr_group);
 	if (err) {
-		printk(KERN_ERR "hugepage: failed register hugeage group\n");
+		printk(KERN_ERR "THP: failed register hugeage group\n");
 		goto out;
 	}
 #endif
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
