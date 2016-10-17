Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DEDAA6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 11:47:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l29so106546829pfg.7
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:47:48 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id e85si31333712pfk.179.2016.10.17.08.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 08:47:48 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id hh10so9370726pac.0
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:47:48 -0700 (PDT)
From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] mm: numa: remove duplicated include from mprotect.c
Date: Mon, 17 Oct 2016 15:47:39 +0000
Message-Id: <1476719259-6214-1-git-send-email-weiyj.lk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Wei Yongjun <weiyongjun1@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Wei Yongjun <weiyongjun1@huawei.com>

Remove duplicated include.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 mm/mprotect.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index bcdbe62..1193652 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -25,7 +25,6 @@
 #include <linux/perf_event.h>
 #include <linux/pkeys.h>
 #include <linux/ksm.h>
-#include <linux/pkeys.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
