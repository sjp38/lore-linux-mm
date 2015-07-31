Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id A69586B0254
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 21:00:29 -0400 (EDT)
Received: by qged69 with SMTP id d69so36474828qge.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 18:00:29 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r10si3638278qkh.34.2015.07.30.18.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jul 2015 18:00:28 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 3/3] Documentation: update libhugetlbfs location and use for testing
Date: Thu, 30 Jul 2015 17:59:53 -0700
Message-Id: <1438304393-30413-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1438304393-30413-1-git-send-email-mike.kravetz@oracle.com>
References: <1438304393-30413-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, joern@purestorage.com
Cc: Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>

The URL for libhugetlbfs has changed.  Also, put a stronger emphasis
on using libgugetlbfs for hugetlb regression testing.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 Documentation/vm/hugetlbpage.txt | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index 030977f..54dd9b9 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -329,7 +329,14 @@ Examples
 
 3) hugepage-mmap:  see tools/testing/selftests/vm/hugepage-mmap.c
 
-4) The libhugetlbfs (http://libhugetlbfs.sourceforge.net) library provides a
-   wide range of userspace tools to help with huge page usability, environment
-   setup, and control. Furthermore it provides useful test cases that should be
-   used when modifying code to ensure no regressions are introduced.
+4) The libhugetlbfs (https://github.com/libhugetlbfs/libhugetlbfs) library
+   provides a wide range of userspace tools to help with huge page usability,
+   environment setup, and control.
+
+Kernel development regression testing
+=====================================
+
+The most complete set of hugetlb tests are in the libhugetlbfs repository.
+If you modify any hugetlb related code, use the libhugetlbfs test suite
+to check for regressions.  In addition, if you add any new hugetlb
+functionality, please add appropriate tests to libhugetlbfs.
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
