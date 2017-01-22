Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 579476B026A
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 08:03:12 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 75so164300553pgf.3
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 05:03:12 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id m18si7497800pgd.142.2017.01.22.05.03.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Jan 2017 05:03:11 -0800 (PST)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: do not export ioremap_page_range symbol for external module
Date: Sun, 22 Jan 2017 20:58:01 +0800
Message-ID: <1485089881-61531-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

Recently, I find the ioremap_page_range had been abusing. The improper
address mapping is a issue. it will result in the crash. so, remove
the symbol. It can be replaced by the ioremap_cache or others symbol.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 lib/ioremap.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 86c8911..a3e14ce 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -144,4 +144,3 @@ int ioremap_page_range(unsigned long addr,
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(ioremap_page_range);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
