Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4B60D6B00D7
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 08:38:07 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so14514940pdb.37
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:38:07 -0800 (PST)
Received: from mail-pd0-x241.google.com (mail-pd0-x241.google.com. [2607:f8b0:400e:c02::241])
        by mx.google.com with ESMTPS id hx9si25642982pad.168.2014.11.13.05.38.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 05:38:06 -0800 (PST)
Received: by mail-pd0-f193.google.com with SMTP id fp1so6532878pdb.0
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:38:05 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH 2/3] mm/zsmalloc: add __init/__exit to zs_init/zs_exit
Date: Thu, 13 Nov 2014 21:37:36 +0800
Message-Id: <1415885857-5283-2-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1415885857-5283-1-git-send-email-opensource.ganesh@gmail.com>
References: <1415885857-5283-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, ddstreet@ieee.org, sergey.senozhatsky@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

After patch [1], the zs_exit is only called in module exit.
So add __init/__exit to zs_init/zs_exit.

  [1] mm/zsmalloc: avoid unregister a NOT-registered zsmalloc zpool driver

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 3d2bb36..92af030 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -881,7 +881,7 @@ static struct notifier_block zs_cpu_nb = {
 	.notifier_call = zs_cpu_notifier
 };
 
-static void zs_exit(void)
+static void __exit zs_exit(void)
 {
 	int cpu;
 
@@ -898,7 +898,7 @@ static void zs_exit(void)
 	cpu_notifier_register_done();
 }
 
-static int zs_init(void)
+static int __init zs_init(void)
 {
 	int cpu, ret;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
