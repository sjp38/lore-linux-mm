Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14BB96B025E
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 02:42:26 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id b13so189313449pat.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:42:26 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id k26si2688889pfk.85.2016.06.30.23.42.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 23:42:25 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id hf6so9026037pac.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:42:25 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH 7/8] mm/zsmalloc: add __init,__exit attribute
Date: Fri,  1 Jul 2016 14:41:05 +0800
Message-Id: <1467355266-9735-7-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

Add __init,__exit attribute for function that is only called in
module init/exit

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 6fc631a..1c7460b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1349,7 +1349,7 @@ static void zs_unregister_cpu_notifier(void)
 	cpu_notifier_register_done();
 }
 
-static void init_zs_size_classes(void)
+static void __init init_zs_size_classes(void)
 {
 	int nr;
 
@@ -1896,7 +1896,7 @@ static struct file_system_type zsmalloc_fs = {
 	.kill_sb	= kill_anon_super,
 };
 
-static int zsmalloc_mount(void)
+static int __init zsmalloc_mount(void)
 {
 	int ret = 0;
 
@@ -1907,7 +1907,7 @@ static int zsmalloc_mount(void)
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
