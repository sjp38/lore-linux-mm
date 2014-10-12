Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BD0666B0038
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 08:03:53 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so4285111pad.25
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 05:03:53 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id yn9si8096469pac.118.2014.10.12.05.03.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sun, 12 Oct 2014 05:03:52 -0700 (PDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDB00EB1YUEJ000@mailout4.samsung.com> for linux-mm@kvack.org;
 Sun, 12 Oct 2014 21:03:50 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH 1/1] [mm]: vmalloc: replace printk with pr_warn
Date: Sun, 12 Oct 2014 17:26:01 +0530
Message-id: <1413114961-10831-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, liwanp@linux.vnet.ibm.com, zhangyanfei@cn.fujitsu.com, rientjes@google.com, edumazet@google.com, chaowang@redhat.com, fabf@skynet.be, catalin.marinas@arm.com, nasa4836@gmail.com, av1474@comtv.ru, gioh.kim@lge.com, rob.jones@codethink.co.uk
Cc: cpgs@samsung.com, pintu.k@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com, iqbal.ams@samsung.com

This patch replaces printk(KERN_WARNING..) with pr_warn.
Thus it also reduces one line extra because of formatting.

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
---
 mm/vmalloc.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 90520af..8a18196 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -463,8 +463,7 @@ overflow:
 		goto retry;
 	}
 	if (printk_ratelimit())
-		printk(KERN_WARNING
-			"vmap allocation for size %lu failed: "
+		pr_warn("vmap allocation for size %lu failed: "
 			"use vmalloc=<size> to increase size.\n", size);
 	kfree(va);
 	return ERR_PTR(-EBUSY);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
