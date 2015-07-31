Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id AD2EB6B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 21:00:28 -0400 (EDT)
Received: by qged69 with SMTP id d69so36474586qge.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 18:00:28 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n33si3642963qkh.21.2015.07.30.18.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 18:00:27 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/3] vm hugetlb selftest cleanup
Date: Thu, 30 Jul 2015 17:59:50 -0700
Message-Id: <1438304393-30413-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, joern@purestorage.com
Cc: Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>

As a followup to discussions of hugetlbfs fallocate, this provides
cleanup the vm hugetlb selftests.  Remove hugetlbfstest as it tests
functionality not present in the kernel.  Emphasize that libhugetlbfs
test suite should be used for hugetlb regression testing.

Mike Kravetz (3):
  Reverted "selftests: add hugetlbfstest"
  selftests:vm: Point to libhugetlbfs for regression testing
  Documentation: update libhugetlbfs location and use for testing

 Documentation/vm/hugetlbpage.txt           | 15 ++++--
 tools/testing/selftests/vm/Makefile        |  2 +-
 tools/testing/selftests/vm/hugetlbfstest.c | 86 ------------------------------
 tools/testing/selftests/vm/run_vmtests     | 13 ++---
 4 files changed, 15 insertions(+), 101 deletions(-)
 delete mode 100644 tools/testing/selftests/vm/hugetlbfstest.c

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
