Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 168FC6B005D
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 07:54:17 -0500 (EST)
From: Jeremy Eder <jeder@redhat.com>
Subject: [PATCH v2] mm: clean up transparent hugepage sysfs error messages
Date: Wed, 19 Dec 2012 07:51:00 -0500
Message-Id: <1355921460-28501-1-git-send-email-jeder@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Jeremy Eder <jeder@redhat.com>

This patch clarifies error messages and corrects a few typos
in the transparent hugepage sysfs init code.

Signed-off-by: Jeremy Eder <jeder@redhat.com>
---
 mm/huge_memory.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 32754ee..9e894ed 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -574,19 +574,19 @@ static int __init hugepage_init_sysfs(struct kobject **hugepage_kobj)
 
 	*hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
 	if (unlikely(!*hugepage_kobj)) {
-		printk(KERN_ERR "hugepage: failed kobject create\n");
+		printk(KERN_ERR "hugepage: failed to create transparent hugepage kobject\n");
 		return -ENOMEM;
 	}
 
 	err = sysfs_create_group(*hugepage_kobj, &hugepage_attr_group);
 	if (err) {
-		printk(KERN_ERR "hugepage: failed register hugeage group\n");
+		printk(KERN_ERR "hugepage: failed to register transparent hugepage group\n");
 		goto delete_obj;
 	}
 
 	err = sysfs_create_group(*hugepage_kobj, &khugepaged_attr_group);
 	if (err) {
-		printk(KERN_ERR "hugepage: failed register hugeage group\n");
+		printk(KERN_ERR "hugepage: failed to register transparent hugepage group\n");
 		goto remove_hp_group;
 	}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
