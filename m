Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B3FA96B0022
	for <linux-mm@kvack.org>; Tue, 17 May 2011 14:26:30 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p4HIQIqT018305
	for <linux-mm@kvack.org>; Tue, 17 May 2011 11:26:23 -0700
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by wpaz9.hot.corp.google.com with ESMTP id p4HIPeWX032474
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 May 2011 11:26:17 -0700
Received: by pvc30 with SMTP id 30so383509pvc.20
        for <linux-mm@kvack.org>; Tue, 17 May 2011 11:26:17 -0700 (PDT)
Date: Tue, 17 May 2011 11:26:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: remove last trace of shmem_get_unmapped_area
Message-ID: <alpine.LSU.2.00.1105171124560.29593@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Remove noMMU declaration of shmem_get_unmapped_area() from mm.h:
it fell out of use in 2.6.21 and ceased to exist in 2.6.29.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 include/linux/mm.h |    8 --------
 1 file changed, 8 deletions(-)

--- mmotm/include/linux/mm.h	2011-05-13 14:57:45.023882876 -0700
+++ linux/include/linux/mm.h	2011-05-17 11:11:49.999177144 -0700
@@ -873,14 +873,6 @@ int shmem_lock(struct file *file, int lo
 struct file *shmem_file_setup(const char *name, loff_t size, unsigned long long vm_flags);
 int shmem_zero_setup(struct vm_area_struct *);
 
-#ifndef CONFIG_MMU
-extern unsigned long shmem_get_unmapped_area(struct file *file,
-					     unsigned long addr,
-					     unsigned long len,
-					     unsigned long pgoff,
-					     unsigned long flags);
-#endif
-
 extern int can_do_mlock(void);
 extern int user_shm_lock(size_t, struct user_struct *);
 extern void user_shm_unlock(size_t, struct user_struct *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
