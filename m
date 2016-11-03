Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A25746B029E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 22:52:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n85so8832388pfi.4
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 19:52:20 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50061.outbound.protection.outlook.com. [40.107.5.61])
        by mx.google.com with ESMTPS id l5si6670336pgk.200.2016.11.02.19.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Nov 2016 19:52:19 -0700 (PDT)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH 0/2] mm: fix the "counter.sh" failure for libhugetlbfs 
Date: Thu, 3 Nov 2016 10:51:36 +0800
Message-ID: <1478141499-13825-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, Huang Shijie <shijie.huang@arm.com>

(1) Background
   For the arm64, the hugetlb page size can be 32M (PMD + Contiguous bit).
   In the 4K page environment, the max page order is 10 (max_order - 1),
   so 32M page is the gigantic page.    

   The arm64 MMU supports a Contiguous bit which is a hint that the TTE
   is one of a set of contiguous entries which can be cached in a single
   TLB entry.  Please refer to the arm64v8 mannul :
       DDI0487A_f_armv8_arm.pdf (in page D4-1811)

(2) The bug   
   After I tested the libhugetlbfs, I found the test case "counter.sh"
   will fail with the gigantic page (32M page in arm64 board).

   This patch set adds support for gigantic surplus hugetlb pages,
   allowing the counter.sh unit test to pass.   


Huang Shijie (2):
  mm: hugetlb: rename some allocation functions
  mm: hugetlb: support gigantic surplus pages

 mm/hugetlb.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
