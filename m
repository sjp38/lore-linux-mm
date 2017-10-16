Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47B6A6B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 18:39:18 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c16so17250858qke.17
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 15:39:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w76si96062qka.243.2017.10.16.15.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 15:39:17 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/1] hugetlbfs: prevent UFFDIO_COPY to fill beyond the end of i_size
Date: Tue, 17 Oct 2017 00:39:13 +0200
Message-Id: <20171016223914.2421-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hello,

The erratic mapping (as in page_mapped()) of hugetlbfs pages beyond
the end of the i_size, was found while testing some userfaultfd
backport. It can trigger a bugcheck as side effect.

Andrea Arcangeli (1):
  userfaultfd: hugetlbfs: prevent UFFDIO_COPY to fill beyond the end of
    i_size

 mm/hugetlb.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
