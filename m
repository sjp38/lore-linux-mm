Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 0F7BC6B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 17:32:03 -0400 (EDT)
From: Joern Engel <joern@logfs.org>
Subject: [PATCH 0/3] Improve selftests
Date: Tue, 18 Jun 2013 16:01:58 -0400
Message-Id: <1371585721-28087-1-git-send-email-joern@logfs.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Joern Engel <joern@logfs.org>

First two are cleanups, third adds hugetlbfstest.  This test fails on
current kernels, but I have previously sent a patchset to fix the two
failures.

Joern Engel (3):
  selftests: exit 1 on failure
  self-test: fix make clean
  selftests: add hugetlbfstest

 tools/testing/selftests/vm/Makefile        |    7 ++-
 tools/testing/selftests/vm/hugetlbfstest.c |   84 ++++++++++++++++++++++++++++
 tools/testing/selftests/vm/run_vmtests     |   16 ++++++
 3 files changed, 104 insertions(+), 3 deletions(-)
 create mode 100644 tools/testing/selftests/vm/hugetlbfstest.c

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
