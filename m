Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 161DB6B0069
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 10:54:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k10so736697wrk.23
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 07:54:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 74si3805413wrm.334.2017.09.29.07.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 07:54:54 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8TEncdG141046
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 10:54:52 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2d9hknre7t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 10:54:52 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sat, 30 Sep 2017 00:54:49 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v8TEsmch42598582
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 00:54:48 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v8TEslNI015480
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 00:54:47 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/hugetlbfs: Remove the redundant -ENIVAL return from hugetlbfs_setattr()
Date: Fri, 29 Sep 2017 20:24:44 +0530
Message-Id: <20170929145444.17611-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: nyc@holomorphy.com

There is no need to have a local return code set with -EINVAL when both the
conditions following it return error codes appropriately. Just remove the
redundant one.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 fs/hugetlbfs/inode.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 59073e9..cff3939 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -668,7 +668,6 @@ static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
 		return error;
 
 	if (ia_valid & ATTR_SIZE) {
-		error = -EINVAL;
 		if (attr->ia_size & ~huge_page_mask(h))
 			return -EINVAL;
 		error = hugetlb_vmtruncate(inode, attr->ia_size);
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
