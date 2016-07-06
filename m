Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A73CE828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 02:26:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so491227729pfa.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:26:46 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id lw5si2520627pab.100.2016.07.05.23.26.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 23:26:46 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id t190so20990144pfb.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:26:45 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v3 6/8] mm/zsmalloc: add __init,__exit attribute
Date: Wed,  6 Jul 2016 14:23:51 +0800
Message-Id: <1467786233-4481-6-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467786233-4481-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

Add __init,__exit attribute for function that only called in
module init/exit to save memory.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
----
v3:
    revert change in v2 - Sergey
v2:
    add __init/__exit for zs_register_cpu_notifier/zs_unregister_cpu_notifier
---
 mm/zsmalloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index ded312b..46526b9 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1344,7 +1344,7 @@ static void zs_unregister_cpu_notifier(void)
 	cpu_notifier_register_done();
 }
 
-static void init_zs_size_classes(void)
+static void __init init_zs_size_classes(void)
 {
 	int nr;
 
@@ -1887,7 +1887,7 @@ static struct file_system_type zsmalloc_fs = {
 	.kill_sb	= kill_anon_super,
 };
 
-static int zsmalloc_mount(void)
+static int __init zsmalloc_mount(void)
 {
 	int ret = 0;
 
@@ -1898,7 +1898,7 @@ static int zsmalloc_mount(void)
 	return ret;
 }
 
-static void zsmalloc_unmount(void)
+static void __exit zsmalloc_unmount(void)
 {
 	kern_unmount(zsmalloc_mnt);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
