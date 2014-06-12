Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 14CAA6B00E8
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 08:56:14 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id md12so138383pbc.33
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 05:56:13 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id zk3si41473524pbb.155.2014.06.12.05.56.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 05:56:13 -0700 (PDT)
Message-ID: <5399A360.3060309@oracle.com>
Date: Thu, 12 Jun 2014 20:56:00 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH] slub: correct return errno on slab_sysfs_init failure
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com

From: Jie Liu <jeff.liu@oracle.com>

Return ENOMEM instead of ENOSYS if slab_sysfs_init() failed

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 2b1ce69..75ca109 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5304,7 +5304,7 @@ static int __init slab_sysfs_init(void)
 	if (!slab_kset) {
 		mutex_unlock(&slab_mutex);
 		printk(KERN_ERR "Cannot register slab subsystem.\n");
-		return -ENOSYS;
+		return -ENOMEM;
 	}
 
 	slab_state = FULL;
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
