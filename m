Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id DE4D180110
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:03:04 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so1744230pdi.31
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 06:03:04 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id yq10si21864638pab.19.2014.11.24.06.03.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 06:03:03 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so9555369pab.12
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 06:03:03 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH] mm/zsmalloc: remove uninitialized_var
Date: Mon, 24 Nov 2014 22:02:47 +0800
Message-Id: <1416837767-6868-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

uninitialized_var() is not recommended to be used  to
avoid compiler warnings
  https://lkml.org/lkml/2012/10/27/71

So this patch initializes ret with *NOTIFY_OK*.

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index bb55736..480fa4c 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -897,7 +897,7 @@ static void zs_unregister_cpu_notifier(void)
 
 static int zs_register_cpu_notifier(void)
 {
-	int cpu, uninitialized_var(ret);
+	int cpu, ret = NOTIFY_OK;
 
 	cpu_notifier_register_begin();
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
