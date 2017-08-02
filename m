Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 433836B05E8
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 12:52:01 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id w51so23485784qtc.12
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 09:52:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q45si29540532qtf.322.2017.08.02.09.52.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 09:52:00 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/6] userfaultfd updates for v4.13-rc3
Date: Wed,  2 Aug 2017 18:51:39 +0200
Message-Id: <20170802165145.22628-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Maxime Coquelin <maxime.coquelin@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Alexey Perevalov <a.perevalov@samsung.com>

Hello,

these are some uffd updates I have pending that looks ready for
merging. vhost-user KVM developement run into a crash so patch 1/6 is
urgent (and simple), the rest is not urgent.

The testcase has been updated to exercise it.

This should apply clean to -mm, and I reviewed in detail all other
userfaultfd patches that are in -mm and they're all great, including
the shmem zeropage addition.

Alexey Perevalov (1):
  userfaultfd: provide pid in userfault msg

Andrea Arcangeli (5):
  userfaultfd: hugetlbfs: remove superfluous page unlock in VM_SHARED
    case
  userfaultfd: selftest: exercise UFFDIO_COPY/ZEROPAGE -EEXIST
  userfaultfd: selftest: explicit failure if the SIGBUS test failed
  userfaultfd: call userfaultfd_unmap_prep only if __split_vma succeeds
  userfaultfd: provide pid in userfault msg - add feat union

 fs/userfaultfd.c                         |   8 +-
 include/uapi/linux/userfaultfd.h         |  12 ++-
 mm/hugetlb.c                             |   2 +-
 mm/mmap.c                                |  22 +++--
 tools/testing/selftests/vm/userfaultfd.c | 149 +++++++++++++++++++++++++++++--
 5 files changed, 172 insertions(+), 21 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
