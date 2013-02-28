Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BD1406B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 18:17:55 -0500 (EST)
From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH] shmem: fix build regression
Date: Fri,  1 Mar 2013 00:17:39 +0100
Message-Id: <1362093459-24608-1-git-send-email-wsa@the-dreams.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Wolfram Sang <wsa@the-dreams.de>, Al Viro <viro@zeniv.linux.org.uk>

commit 6b4d0b27 (clean shmem_file_setup() a bit) broke allnoconfig since
this needs the NOMMU path where 'error' is still needed:

mm/shmem.c:2935:2: error: 'error' undeclared (first use in this function)

Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---
 mm/shmem.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index ed2befb..56ff7d7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2897,6 +2897,7 @@ static struct dentry_operations anon_ops = {
  */
 struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags)
 {
+	int error;
 	struct file *res;
 	struct inode *inode;
 	struct path path;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
