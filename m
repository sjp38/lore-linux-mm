Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id A60636B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:59:05 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so21175618obb.13
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:59:05 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t5si2793399oes.86.2015.02.27.14.59.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 14:59:04 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC 0/3] hugetlbfs: optionally reserve all fs pages at mount time
Date: Fri, 27 Feb 2015 14:58:08 -0800
Message-Id: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

hugetlbfs allocates huge pages from the global pool as needed.  Even if
the global pool contains a sufficient number pages for the filesystem
size at mount time, those global pages could be grabbed for some other
use.  As a result, filesystem huge page allocations may fail due to lack
of pages.

Add a new hugetlbfs mount option 'reserved' to specify that the number
of pages associated with the size of the filesystem will be reserved.  If
there are insufficient pages, the mount will fail.  The reservation is
maintained for the duration of the filesystem so that as pages are
allocated and free'ed a sufficient number of pages remains reserved.

Mike Kravetz (3):
  hugetlbfs: add reserved mount fields to subpool structure
  hugetlbfs: coordinate global and subpool reserve accounting
  hugetlbfs: accept subpool reserved option and setup accordingly

 fs/hugetlbfs/inode.c    | 15 +++++++++++++--
 include/linux/hugetlb.h |  7 +++++++
 mm/hugetlb.c            | 37 +++++++++++++++++++++++++++++--------
 3 files changed, 49 insertions(+), 10 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
