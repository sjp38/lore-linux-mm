Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0676B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 05:38:05 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id ma3so1749294pbc.29
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 02:38:05 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id kv4si5234473pab.78.2014.06.19.02.38.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 02:38:04 -0700 (PDT)
Message-ID: <53A2AEB4.40608@huawei.com>
Date: Thu, 19 Jun 2014 17:34:44 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v2] mm/mem-hotplug: replace simple_strtoull() with kstrtoull()
References: <1403170456-25054-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1403170456-25054-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nfont@austin.ibm.com, akpm@linux-foundation.org, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org

use the newer and more pleasant kstrtoull() to replace simple_strtoull(),
because simple_strtoull() is marked for obsoletion.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 drivers/base/memory.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 89f752d..4fee600 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -406,7 +406,9 @@ memory_probe_store(struct device *dev, struct device_attribute *attr,
 	int i, ret;
 	unsigned long pages_per_block = PAGES_PER_SECTION * sections_per_block;

-	phys_addr = simple_strtoull(buf, NULL, 0);
+	ret = kstrtoull(buf, 0, &phys_addr);
+	if (ret)
+		return ret;

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
