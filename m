Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 811DF8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 13:04:12 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id c24-v6so4054595otm.4
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 10:04:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x62-v6si1111220oif.93.2018.09.27.10.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 10:04:11 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8RH4ASO058818
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 13:04:11 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ms293tukw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 13:04:10 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 27 Sep 2018 18:03:59 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] memblock: remove stale #else and the code it protects
Date: Thu, 27 Sep 2018 20:03:45 +0300
Message-Id: <1538067825-24835-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

During removal of HAVE_MEMBLOCK definition, the #else clause of the

	#ifdef CONFIG_HAVE_MEMBLOCK
		...
	#else
		...
	#endif

conditional was not removed.

Remove it now.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
---
 include/linux/memblock.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index d3bc270..d4d0e01 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -597,11 +597,6 @@ static inline void early_memtest(phys_addr_t start, phys_addr_t end)
 {
 }
 #endif
-#else
-static inline phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align)
-{
-	return 0;
-}
 
 #endif /* __KERNEL__ */
 
-- 
2.7.4
