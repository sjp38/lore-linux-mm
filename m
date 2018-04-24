Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77AF26B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:43 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c20so2131020qkm.13
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:40:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j190si747687qkf.393.2018.04.23.23.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:40:42 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3O6ePxp020673
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:41 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hhvy7egu3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:40 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Apr 2018 07:40:38 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/7] mm/ksm: docs: extend overview comment and make it "DOC:"
Date: Tue, 24 Apr 2018 09:40:22 +0300
In-Reply-To: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524552028-7017-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The existing comment provides a good overview of KSM implementation. Let's
update it to reflect recent additions of "chain" and "dup" variants of the
stable tree nodes and mark it as "DOC:" for inclusion into the KSM
documentation.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/ksm.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 58c2741..54155b1 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -51,7 +51,9 @@
 #define DO_NUMA(x)	do { } while (0)
 #endif
 
-/*
+/**
+ * DOC: Overview
+ *
  * A few notes about the KSM scanning process,
  * to make it easier to understand the data structures below:
  *
@@ -67,6 +69,21 @@
  * this tree is fully assured to be working (except when pages are unmapped),
  * and therefore this tree is called the stable tree.
  *
+ * The stable tree node includes information required for reverse
+ * mapping from a KSM page to virtual addresses that map this page.
+ *
+ * In order to avoid large latencies of the rmap walks on KSM pages,
+ * KSM maintains two types of nodes in the stable tree:
+ *
+ * * the regular nodes that keep the reverse mapping structures in a
+ *   linked list
+ * * the "chains" that link nodes ("dups") that represent the same
+ *   write protected memory content, but each "dup" corresponds to a
+ *   different KSM page copy of that content
+ *
+ * Internally, the regular nodes, "dups" and "chains" are represented
+ * using the same :c:type:`struct stable_node` structure.
+ *
  * In addition to the stable tree, KSM uses a second data structure called the
  * unstable tree: this tree holds pointers to pages which have been found to
  * be "unchanged for a period of time".  The unstable tree sorts these pages
-- 
2.7.4
