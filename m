Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5676B0099
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 18:39:51 -0400 (EDT)
Received: by oier21 with SMTP id r21so11941983oie.1
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 15:39:51 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id d142si511969oig.0.2015.03.14.15.39.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Mar 2015 15:39:50 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 4/4] kernel/fork: use pr_alert() for rss counter bugs
Date: Sat, 14 Mar 2015 15:39:26 -0700
Message-Id: <1426372766-3029-5-git-send-email-dave@stgolabs.net>
In-Reply-To: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: viro@zeniv.linux.org.uk, gorcunov@openvz.org, oleg@redhat.com, koct9i@gmail.com, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

... everyone else does.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>
CC: Konstantin Khlebnikov <koct9i@gmail.com>
---
 kernel/fork.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 54b0b91..fc5d4f3 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -602,8 +602,8 @@ static void check_mm(struct mm_struct *mm)
 		long x = atomic_long_read(&mm->rss_stat.count[i]);
 
 		if (unlikely(x))
-			printk(KERN_ALERT "BUG: Bad rss-counter state "
-					  "mm:%p idx:%d val:%ld\n", mm, i, x);
+			pr_alert("BUG: Bad rss-counter state "
+				 "mm:%p idx:%d val:%ld\n", mm, i, x);
 	}
 
 	if (atomic_long_read(&mm->nr_ptes))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
