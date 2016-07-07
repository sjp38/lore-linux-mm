Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3744B6B0261
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:06:42 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id b13so22262159pat.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:06:42 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id u2si3180046pax.197.2016.07.07.02.06.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 02:06:41 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id c74so1296528pfb.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:06:41 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v4 6/8] mm/zsmalloc: add __init,__exit attribute
Date: Thu,  7 Jul 2016 17:05:36 +0800
Message-Id: <1467882338-4300-6-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467882338-4300-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467882338-4300-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, mingo@redhat.com, rostedt@goodmis.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

Add __init,__exit attribute for function that only called in
module init/exit to save memory.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
----
v4:
    remove __init/__exit from zsmalloc_mount/zsmalloc_umount
v3:
    revert change in v2 - Sergey
v2:
    add __init/__exit for zs_register_cpu_notifier/zs_unregister_cpu_notifier
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index ded312b..780eabd 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1344,7 +1344,7 @@ static void zs_unregister_cpu_notifier(void)
 	cpu_notifier_register_done();
 }
 
-static void init_zs_size_classes(void)
+static void __init init_zs_size_classes(void)
 {
 	int nr;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
