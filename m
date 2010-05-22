Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 945D56B01B5
	for <linux-mm@kvack.org>; Sat, 22 May 2010 14:09:01 -0400 (EDT)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 22 May 2010 18:08:57 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 1/3] mm/swapfile.c: better messages for swap_info_get
Date: Sat, 22 May 2010 15:08:49 -0300
Message-Id: <1274551731-4534-1-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4BF81D87.6010506@cesarb.net>
References: <4BF81D87.6010506@cesarb.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cesar Eduardo Barros <cesarb@cesarb.net>
List-ID: <linux-mm.kvack.org>

swap_info_get() is used for more than swap_free().

Use "swap_info_get:" instead of "swap_free:" in the error messages.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6cd0a8f..af7d499 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -522,16 +522,16 @@ static struct swap_info_struct *swap_info_get(swp_entry_t entry)
 	return p;
 
 bad_free:
-	printk(KERN_ERR "swap_free: %s%08lx\n", Unused_offset, entry.val);
+	printk(KERN_ERR "swap_info_get: %s%08lx\n", Unused_offset, entry.val);
 	goto out;
 bad_offset:
-	printk(KERN_ERR "swap_free: %s%08lx\n", Bad_offset, entry.val);
+	printk(KERN_ERR "swap_info_get: %s%08lx\n", Bad_offset, entry.val);
 	goto out;
 bad_device:
-	printk(KERN_ERR "swap_free: %s%08lx\n", Unused_file, entry.val);
+	printk(KERN_ERR "swap_info_get: %s%08lx\n", Unused_file, entry.val);
 	goto out;
 bad_nofile:
-	printk(KERN_ERR "swap_free: %s%08lx\n", Bad_file, entry.val);
+	printk(KERN_ERR "swap_info_get: %s%08lx\n", Bad_file, entry.val);
 out:
 	return NULL;
 }
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
