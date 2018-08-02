Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D17A76B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 03:59:35 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id m21-v6so1224660oic.7
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 00:59:35 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id y129-v6si855691oiy.462.2018.08.02.00.59.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 00:59:34 -0700 (PDT)
From: <chenjie6@huawei.com>
Subject: [PATCH] mm:bugfix check return value of ioremap_prot
Date: Thu, 2 Aug 2018 07:37:21 +0000
Message-ID: <1533195441-58594-1-git-send-email-chenjie6@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, tj@kernel.org
Cc: akpm@linux-foundation.org, lizefan@huawei.com, chen jie <"chen jie@chenjie6"@huwei.com>, chen jie <chenjie6@huawei.com>

From: chen jie <chen jie@chenjie6@huwei.com>

	ioremap_prot can return NULL which could lead to an oops

Signed-off-by: chen jie <chenjie6@huawei.com>
---
 mm/memory.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 7206a63..316c42e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4397,6 +4397,9 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 		return -EINVAL;
 
 	maddr = ioremap_prot(phys_addr, PAGE_ALIGN(len + offset), prot);
+	if (!maddr)
+		return -ENOMEM;
+
 	if (write)
 		memcpy_toio(maddr + offset, buf, len);
 	else
-- 
1.8.3.4
