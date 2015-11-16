Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 888F26B025A
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 01:53:07 -0500 (EST)
Received: by padhx2 with SMTP id hx2so165588906pad.1
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 22:53:07 -0800 (PST)
Received: from cmccmta3.chinamobile.com (cmccmta3.chinamobile.com. [221.176.66.81])
        by mx.google.com with ESMTP id ry4si353404pac.153.2015.11.15.22.52.38
        for <linux-mm@kvack.org>;
        Sun, 15 Nov 2015 22:53:06 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 2/7] mm/hugetlb: is_file_hugepages can be boolean
Date: Mon, 16 Nov 2015 14:51:21 +0800
Message-Id: <1447656686-4851-3-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch makes is_file_hugepages return bool to improve
readability due to this particular function only using either
one or zero as its return value.

This patch also removed the if condition to make is_file_hugepages
return directly.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/hugetlb.h | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 685c262..204c7f5 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -265,20 +265,18 @@ struct file *hugetlb_file_setup(const char *name, size_t size, vm_flags_t acct,
 				struct user_struct **user, int creat_flags,
 				int page_size_log);
 
-static inline int is_file_hugepages(struct file *file)
+static inline bool is_file_hugepages(struct file *file)
 {
 	if (file->f_op == &hugetlbfs_file_operations)
-		return 1;
-	if (is_file_shm_hugepages(file))
-		return 1;
+		return true;
 
-	return 0;
+	return is_file_shm_hugepages(file);
 }
 
 
 #else /* !CONFIG_HUGETLBFS */
 
-#define is_file_hugepages(file)			0
+#define is_file_hugepages(file)			false
 static inline struct file *
 hugetlb_file_setup(const char *name, size_t size, vm_flags_t acctflag,
 		struct user_struct **user, int creat_flags,
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
