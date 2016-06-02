Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id A6F2E6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 02:15:47 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so35303256pad.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:15:47 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id j2si20886788paw.80.2016.06.01.23.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 23:15:46 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id b124so6775320pfb.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:15:46 -0700 (PDT)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH 1/4] mm/init-mm: remove unused header cpumask.h
Date: Thu,  2 Jun 2016 14:15:33 +0800
Message-Id: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Remove unused header cpumask.h from mm/init-mm.c.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 mm/init-mm.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/init-mm.c b/mm/init-mm.c
index a56a851..2acae89 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -3,7 +3,6 @@
 #include <linux/rwsem.h>
 #include <linux/spinlock.h>
 #include <linux/list.h>
-#include <linux/cpumask.h>
 
 #include <linux/atomic.h>
 #include <asm/pgtable.h>
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
