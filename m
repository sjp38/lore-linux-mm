Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75A558E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 09:13:34 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id c8-v6so7832906plz.0
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 06:13:34 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id u20-v6si15487657plq.210.2018.09.17.06.13.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 06:13:33 -0700 (PDT)
From: YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH -next] mm: swap: remove duplicated include from swap.c
Date: Mon, 17 Sep 2018 21:13:08 +0800
Message-ID: <20180917131308.16420-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, jack@suse.cz, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, shakeelb@google.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, YueHaibing <yuehaibing@huawei.com>

Remove duplicated include linux/memremap.h

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 mm/swap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index 26fc9b5..87a54c8 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -29,7 +29,6 @@
 #include <linux/cpu.h>
 #include <linux/notifier.h>
 #include <linux/backing-dev.h>
-#include <linux/memremap.h>
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
 #include <linux/uio.h>
-- 
2.7.0
