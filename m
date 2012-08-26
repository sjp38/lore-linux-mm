Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E097F6B002B
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 21:34:35 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2357364qcs.14
        for <linux-mm@kvack.org>; Sat, 25 Aug 2012 18:34:31 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 26 Aug 2012 09:34:31 +0800
Message-ID: <CAPgLHd9zgUBU+aWLhiFW8t5Jx=xCFk8WZim0J9TgBqg83jznSQ@mail.gmail.com>
Subject: [PATCH] hugetlb: remove duplicated include from hugetlb.c
From: Wei Yongjun <weiyj.lk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: yongjun_wei@trendmicro.com.cn

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

To: linux-mm@kvack.org,
    linux-kernel@vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 mm/hugetlb.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bc72712..5bf325b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -30,7 +30,6 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/node.h>
-#include <linux/hugetlb_cgroup.h>
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
