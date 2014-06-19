Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CCEA16B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 03:50:20 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so1643490pab.2
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 00:50:20 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id ry7si4910031pab.188.2014.06.19.00.50.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 00:50:19 -0700 (PDT)
Message-ID: <53A2962B.9070904@huawei.com>
Date: Thu, 19 Jun 2014 15:50:03 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/mem-hotplug: replace simple_strtoul() with kstrtoul()
References: <1403151749-14013-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1403151749-14013-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nfont@austin.ibm.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

use the newer and more pleasant kstrtoul() to replace simple_strtoul(),
because simple_strtoul() is marked for obsoletion.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 drivers/base/memory.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 89f752d..c1b118a 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -406,7 +406,9 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
 	int i, ret;
 	unsigned long pages_per_block = PAGES_PER_SECTION * sections_per_block;

-	phys_addr = simple_strtoull(buf, NULL, 0);
+	ret = kstrtoull(buf, 0, phys_addr);
+	if (ret)
+		return -EINVAL;

 	if (phys_addr & ((pages_per_block << PAGE_SHIFT) - 1))
 		return -EINVAL;
-- 
1.8.1.2


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
