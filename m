Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E960D6B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 00:57:37 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m28so163822252pgn.14
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 21:57:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a21si16248941pfh.134.2017.04.03.21.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 21:57:36 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v344rqgL127795
	for <linux-mm@kvack.org>; Tue, 4 Apr 2017 00:57:36 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29m21m77yd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Apr 2017 00:57:35 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 4 Apr 2017 14:57:33 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v344vNmZ54657114
	for <linux-mm@kvack.org>; Tue, 4 Apr 2017 14:57:31 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v344utWa001474
	for <linux-mm@kvack.org>; Tue, 4 Apr 2017 14:56:55 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/mmap: Replace SHM_HUGE_MASK with MAP_HUGE_MASK inside mmap_pgoff
Date: Tue,  4 Apr 2017 10:26:35 +0530
Message-Id: <20170404045635.616-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, bsingharora@gmail.com, akpm@linux-foundation.org

The commit 091d0d55b286 ("shm: fix null pointer deref when userspace
specifies invalid hugepage size") had replaced MAP_HUGE_MASK with
SHM_HUGE_MASK. Though both of them contain the same numeric value of
0x3f, MAP_HUGE_MASK flag sounds more appropriate than the other one
in the context. Hence change it back.

Acked-by: Balbir Singh <bsingharora@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
Posted this last year (https://patchwork.kernel.org/patch/8768891/) and
then forgot to follow up. Sorry about that.

 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index bfbe885..f82741e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1479,7 +1479,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 		struct user_struct *user = NULL;
 		struct hstate *hs;
 
-		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & SHM_HUGE_MASK);
+		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
 		if (!hs)
 			return -EINVAL;
 
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
