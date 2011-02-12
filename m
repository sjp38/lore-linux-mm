Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CECAD8D003F
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:46 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:43 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 07/24] sys_swapon: remove initial value of name variable
Date: Sat, 12 Feb 2011 16:49:08 -0200
Message-Id: <1297536565-8059-7-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

Now there is nothing which jumps to the cleanup blocks before the name
variable is set. There is no need to set it initially to NULL anymore.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5538c77..e21602c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1892,7 +1892,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 {
 	struct swap_info_struct *p;
-	char *name = NULL;
+	char *name;
 	struct block_device *bdev = NULL;
 	struct file *swap_file = NULL;
 	struct address_space *mapping;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
