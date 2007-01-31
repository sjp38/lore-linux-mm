Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l0VKHVop024554
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 15:17:31 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0VKHVOL547810
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 13:17:31 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0VKHUkC013295
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 13:17:31 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 6/6] hugetlb: Remove is_file_hugepages()
Date: Wed, 31 Jan 2007 12:17:29 -0800
Message-Id: <20070131201728.13810.56480.stgit@localhost.localdomain>
In-Reply-To: <20070131201624.13810.45848.stgit@localhost.localdomain>
References: <20070131201624.13810.45848.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, hugh@veritas.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

Now that they have no users, remove the is_file_hugepages() and
set_file_hugepages() macros.

This unshackles the file_operations structure and permits future interfaces
to hugetlb pages to define their own file_operations, distinct from those
currently used by hugetlbfs.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 include/linux/hugetlb.h |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index a184933..ec3ce89 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -162,20 +162,8 @@ extern struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_zero_setup(size_t);
 int hugetlb_get_quota(struct address_space *mapping);
 void hugetlb_put_quota(struct address_space *mapping);
-
-static inline int is_file_hugepages(struct file *file)
-{
-	return file->f_op == &hugetlbfs_file_operations;
-}
-
-static inline void set_file_hugepages(struct file *file)
-{
-	file->f_op = &hugetlbfs_file_operations;
-}
 #else /* !CONFIG_HUGETLBFS */
 
-#define is_file_hugepages(file)		0
-#define set_file_hugepages(file)	BUG()
 #define hugetlb_zero_setup(size)	ERR_PTR(-ENOSYS)
 
 #endif /* !CONFIG_HUGETLBFS */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
