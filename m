Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B4BF66B0273
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 20:19:47 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so2020170pgj.6
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 17:19:47 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id v3si20705679plk.296.2017.02.01.17.19.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 17:19:46 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 204so179439pge.2
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 17:19:46 -0800 (PST)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [linux-next]mm:page_alloc: Remove duplicate page_ext.h
Date: Thu,  2 Feb 2017 10:19:42 +0900
Message-Id: <20170202011942.1609-1-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, trivial@kernel.org
Cc: Masanari Iida <standby24x7@gmail.com>

This patch removes duplicate page_ext.h from page_alloc.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 mm/page_alloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 11b4cd48a355..4da0b5febf0d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -59,7 +59,6 @@
 #include <linux/prefetch.h>
 #include <linux/mm_inline.h>
 #include <linux/migrate.h>
-#include <linux/page_ext.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
 #include <linux/page_owner.h>
-- 
2.11.0.616.g8f60064c1f53

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
