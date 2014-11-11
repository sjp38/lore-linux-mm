Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9CEE46B0129
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 04:15:14 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so10286731pab.32
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 01:15:14 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id dm8si243356pdb.15.2014.11.11.01.15.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 01:15:13 -0800 (PST)
Message-ID: <5461D343.60803@huawei.com>
Date: Tue, 11 Nov 2014 17:13:39 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] memory-hotplug: remove redundant call of page_to_pfn
References: <1415697184-26409-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1415697184-26409-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: wangnan0@huawei.com

The start_pfn can be obtained directly by
phys_index << PFN_SECTION_SHIFT.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 drivers/base/memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 7c5d871..85be040 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -228,8 +228,8 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
 	struct page *first_page;
 	int ret;

-	first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
-	start_pfn = page_to_pfn(first_page);
+	start_pfn = phys_index << PFN_SECTION_SHIFT;
+	first_page = pfn_to_page(start_pfn);

 	switch (action) {
 		case MEM_ONLINE:
-- 
1.8.1.4


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
