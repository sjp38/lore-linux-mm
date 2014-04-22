Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 54C036B0038
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 01:30:30 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so4478082pbb.8
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 22:30:29 -0700 (PDT)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id as3si22050327pbc.479.2014.04.21.22.30.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 22:30:29 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so562598pbb.39
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 22:30:29 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] hugetlb_cgroup: explicitly init the early_init field
Date: Tue, 22 Apr 2014 13:30:20 +0800
Message-Id: <1398144620-9630-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, lizefan@huawei.com
Cc: containers@lists.linux-foundation.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

For a cgroup subsystem who should init early, then it should carefully
take care of the implementation of css_alloc, because it will be called
before mm_init() setup the world.

Luckily we don't, and we better explicitly assign the early_init field
to 0, for document reason.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/hugetlb_cgroup.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 595d7fd..b5368f8 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -405,4 +405,5 @@ struct cgroup_subsys hugetlb_cgrp_subsys = {
 	.css_alloc	= hugetlb_cgroup_css_alloc,
 	.css_offline	= hugetlb_cgroup_css_offline,
 	.css_free	= hugetlb_cgroup_css_free,
+	.early_init	= 0,
 };
-- 
2.0.0-rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
