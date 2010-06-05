Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A6A3C6B01B0
	for <linux-mm@kvack.org>; Sat,  5 Jun 2010 19:14:48 -0400 (EDT)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-02.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 5 Jun 2010 23:14:43 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH v2 1/3] mm/swapfile.c: better messages for swap_info_get
Date: Sat,  5 Jun 2010 20:14:34 -0300
Message-Id: <1275779676-19120-1-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4C0ADA44.4020406@cesarb.net>
References: <4C0ADA44.4020406@cesarb.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, Avi Kivity <avi@redhat.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jens.axboe@oracle.com>, Hugh Dickins <hughd@google.com>, Cesar Eduardo Barros <cesarb@cesarb.net>
List-ID: <linux-mm.kvack.org>

swap_info_get() is used for more than swap_free().

Use "swap_info_get:" instead of "swap_free:" in the error messages.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 03aa2d5..68765c9 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -525,16 +525,16 @@ static struct swap_info_struct *swap_info_get(swp_entry_t entry)
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
