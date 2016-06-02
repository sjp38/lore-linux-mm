Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18ED96B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 02:15:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b124so39689963pfb.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:15:50 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id k4si1963979paa.181.2016.06.01.23.15.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 23:15:49 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id f144so6784237pfa.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:15:49 -0700 (PDT)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH 2/4] mm: kmemleak: remove unused header cpumask.h
Date: Thu,  2 Jun 2016 14:15:34 +0800
Message-Id: <f0fa3738403f886988141182e8e4bac7efed05c7.1464847139.git.geliangtang@gmail.com>
In-Reply-To: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
In-Reply-To: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Remove unused header cpumask.h from mm/kmemleak.c.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 mm/kmemleak.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index e642992..2617309 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -82,7 +82,6 @@
 #include <linux/fs.h>
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
-#include <linux/cpumask.h>
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
 #include <linux/rcupdate.h>
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
