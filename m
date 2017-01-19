Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27CC16B0268
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:23:00 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 75so48015835pgf.3
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 00:23:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k19si2835843pfk.257.2017.01.19.00.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 00:22:59 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0J8E6Lo117676
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:22:58 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 282rgcu01p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:22:58 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 19 Jan 2017 08:22:52 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/3] userfaultfd: non-cooperative: add madvise() event for MADV_REMOVE request
Date: Thu, 19 Jan 2017 10:22:31 +0200
Message-Id: <1484814154-1557-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches add notification of madvise(MADV_REMOVE) event to
non-cooperative userfaultfd monitor.

The first pacth renames EVENT_MADVDONTNEED to EVENT_REMOVE along with
relevant functions and structures. Using _REMOVE instead of _MADVDONTNEED
describes the event semantics more clearly and I hope it's not too late for
such change in the ABI.

The patches are against current -mm tree.

Mike Rapoport (3):
  userfaultfd: non-cooperative: rename *EVENT_MADVDONTNEED to *EVENT_REMOVE
  userfaultfd: non-cooperative: add madvise() event for MADV_REMOVE request
  userfaultfd: non-cooperative: selftest: enable REMOVE event test for shmem

 fs/userfaultfd.c                         | 14 +++++++-------
 include/linux/userfaultfd_k.h            | 16 ++++++++--------
 include/uapi/linux/userfaultfd.h         |  8 ++++----
 mm/madvise.c                             |  3 ++-
 tools/testing/selftests/vm/userfaultfd.c | 22 ++++++++++------------
 5 files changed, 31 insertions(+), 32 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
