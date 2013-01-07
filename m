Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 468926B005D
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 22:26:35 -0500 (EST)
From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: [PATCH] exec: let bprm_mm_init() be static
Date: Mon,  7 Jan 2013 11:27:15 +0800
Message-Id: <1357529235-25399-1-git-send-email-yuanhan.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yuanhan Liu <yuanhan.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

There is only one user of bprm_mm_init, and it's inside the same file.
So, let it be static.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
---
 fs/exec.c               |    2 +-
 include/linux/binfmts.h |    1 -
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 18c45ca..b72cd2f 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -355,7 +355,7 @@ static bool valid_arg_len(struct linux_binprm *bprm, long len)
  * flags, permissions, and offset, so we use temporary values.  We'll update
  * them later in setup_arg_pages().
  */
-int bprm_mm_init(struct linux_binprm *bprm)
+static int bprm_mm_init(struct linux_binprm *bprm)
 {
 	int err;
 	struct mm_struct *mm = NULL;
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index 0530b98..c3a0914 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -111,7 +111,6 @@ extern int suid_dumpable;
 extern int setup_arg_pages(struct linux_binprm * bprm,
 			   unsigned long stack_top,
 			   int executable_stack);
-extern int bprm_mm_init(struct linux_binprm *bprm);
 extern int bprm_change_interp(char *interp, struct linux_binprm *bprm);
 extern int copy_strings_kernel(int argc, const char *const *argv,
 			       struct linux_binprm *bprm);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
