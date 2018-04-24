Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C40096B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:42:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f23-v6so16827478wra.20
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:42:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r5si9790458edb.212.2018.04.23.23.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:42:08 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3O6dENE125267
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:42:07 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hhybrrhm2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:42:06 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Apr 2018 07:42:05 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm/ksm: remove unused page_referenced_ksm declaration
Date: Tue, 24 Apr 2018 09:41:45 +0300
In-Reply-To: <1524552106-7356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524552106-7356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524552106-7356-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The commit 9f32624be943538983e ("mm/rmap: use rmap_walk() in
page_referenced()") removed the declaration of page_referenced_ksm for the
case CONFIG_KSM=y, but left one for CONFIG_KSM=n.

Remove the unused leftover.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/ksm.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 44368b1..bbdfca3 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -89,12 +89,6 @@ static inline struct page *ksm_might_need_to_copy(struct page *page,
 	return page;
 }
 
-static inline int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags)
-{
-	return 0;
-}
-
 static inline void rmap_walk_ksm(struct page *page,
 			struct rmap_walk_control *rwc)
 {
-- 
2.7.4
