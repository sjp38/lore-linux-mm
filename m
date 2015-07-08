Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9596F6B0255
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 06:50:17 -0400 (EDT)
Received: by qkeo142 with SMTP id o142so159730385qke.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 03:50:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p105si2415155qgd.86.2015.07.08.03.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 03:50:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/5] userfaultfd21 updates v2
Date: Wed,  8 Jul 2015 12:50:03 +0200
Message-Id: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Dave Hansen <dave.hansen@intel.com>

Hello everyone,

This is an update for userfaultfd to synchronize -mm with the code
in the userfaultfd21 git branch.

It includes: two fixes for some minor problem found with the selftest
(qemu wouldn't trigger those), one debuggability improvement for gdb,
the selftest itself and it adds one check to verify the API was
followed in some case.

The wakeone patch is present in the userfault21 branch but it's
deferred because it's just a minor optimization and the "require
UFFDIO_API before other ioctls" patch has been updated according to
upstream review of the previous submit of this update.

Andrea Arcangeli (5):
  userfaultfd: require UFFDIO_API before other ioctls
  userfaultfd: allow signals to interrupt a userfault
  userfaultfd: propagate the full address in THP faults
  userfaultfd: avoid missing wakeups during refile in userfaultfd_read
  userfaultfd: selftest

 fs/userfaultfd.c                         |  65 +++-
 mm/huge_memory.c                         |  10 +-
 tools/testing/selftests/vm/Makefile      |   3 +
 tools/testing/selftests/vm/run_vmtests   |  11 +
 tools/testing/selftests/vm/userfaultfd.c | 636 +++++++++++++++++++++++++++++++
 5 files changed, 715 insertions(+), 10 deletions(-)
 create mode 100644 tools/testing/selftests/vm/userfaultfd.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
