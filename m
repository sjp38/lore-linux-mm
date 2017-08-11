Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D386B6B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 19:56:34 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h70so55334581ioi.14
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 16:56:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m81si1897874ioa.188.2017.08.11.16.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 16:56:33 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/2] Add hugetlbfs support to memfd_create()
Date: Fri, 11 Aug 2017 16:56:10 -0700
Message-Id: <1502495772-24736-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

This is a resend of the patch sent in the RFC:
http://lkml.kernel.org/r/1502149672-7759-1-git-send-email-mike.kravetz@oracle.com

It addresses the issues with the commit message raised by Michal Hocko.
Only the commit message is modified, the code from the RFC patch is the
same.

In addition, a new patch is included to modify the memfd selftest.  The
modifications allow basic functionality testing of memfd_create with
hugetlbfs.

Mike Kravetz (2):
  mm/shmem: add hugetlbfs support to memfd_create()
  selftests/memfd: Add memfd_create hugetlbfs selftest

 include/uapi/linux/memfd.h                 |  24 ++
 mm/shmem.c                                 |  37 ++-
 tools/testing/selftests/memfd/Makefile     |   2 +-
 tools/testing/selftests/memfd/memfd_test.c | 372 ++++++++++++++++++++++-------
 tools/testing/selftests/memfd/run_tests.sh |  69 ++++++
 5 files changed, 412 insertions(+), 92 deletions(-)
 create mode 100755 tools/testing/selftests/memfd/run_tests.sh

-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
