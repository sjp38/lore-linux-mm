Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 822E36B0254
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 01:52:39 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so167713128pab.0
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 22:52:39 -0800 (PST)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id qk3si48249537pac.28.2015.11.15.22.52.37
        for <linux-mm@kvack.org>;
        Sun, 15 Nov 2015 22:52:38 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH 1/7] ipc/shm: is_file_shm_hugepages can be boolean
Date: Mon, 16 Nov 2015 14:51:20 +0800
Message-Id: <1447656686-4851-2-git-send-email-baiyaowei@cmss.chinamobile.com>
In-Reply-To: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mhocko@suse.cz, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch makes is_file_shm_hugepages return bool to improve
readability due to this particular function only using either
one or zero as its return value.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 include/linux/shm.h | 6 +++---
 ipc/shm.c           | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 6fb8016..04e8818 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -52,7 +52,7 @@ struct sysv_shm {
 
 long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr,
 	      unsigned long shmlba);
-int is_file_shm_hugepages(struct file *file);
+bool is_file_shm_hugepages(struct file *file);
 void exit_shm(struct task_struct *task);
 #define shm_init_task(task) INIT_LIST_HEAD(&(task)->sysvshm.shm_clist)
 #else
@@ -66,9 +66,9 @@ static inline long do_shmat(int shmid, char __user *shmaddr,
 {
 	return -ENOSYS;
 }
-static inline int is_file_shm_hugepages(struct file *file)
+static inline bool is_file_shm_hugepages(struct file *file)
 {
-	return 0;
+	return false;
 }
 static inline void exit_shm(struct task_struct *task)
 {
diff --git a/ipc/shm.c b/ipc/shm.c
index 4178727..ed3027d 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -459,7 +459,7 @@ static const struct file_operations shm_file_operations_huge = {
 	.fallocate	= shm_fallocate,
 };
 
-int is_file_shm_hugepages(struct file *file)
+bool is_file_shm_hugepages(struct file *file)
 {
 	return file->f_op == &shm_file_operations_huge;
 }
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
