Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 690086B000A
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:55 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r16so8095634qkk.21
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:40:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x54-v6si2245680qth.369.2018.04.23.23.40.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:40:54 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3O6eTqs071269
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:53 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hhxx89t5r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:53 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Apr 2018 07:40:48 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 6/7] docs/vm: ksm: udpate description of stable_node_{dups,chains}
Date: Tue, 24 Apr 2018 09:40:27 +0300
In-Reply-To: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524552028-7017-7-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Remove implementation details from sysfs parameter descriptions.
Also move the paragraph discussing fragmentation issues and their possible
solution to the "Design" section.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/ksm.rst | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/Documentation/vm/ksm.rst b/Documentation/vm/ksm.rst
index 18d7c71..afcf5a8 100644
--- a/Documentation/vm/ksm.rst
+++ b/Documentation/vm/ksm.rst
@@ -170,10 +170,9 @@ pages_volatile
 full_scans
         how many times all mergeable areas have been scanned
 stable_node_chains
-        number of stable node chains allocated, this is effectively
         the number of KSM pages that hit the ``max_page_sharing`` limit
 stable_node_dups
-        number of stable node dups queued into the stable_node chains
+        number of duplicated KSM pages
 
 A high ratio of ``pages_sharing`` to ``pages_shared`` indicates good
 sharing, but a high ratio of ``pages_unshared`` to ``pages_sharing``
@@ -185,15 +184,6 @@ The maximum possible ``pages_sharing/pages_shared`` ratio is limited by the
 ``max_page_sharing`` tunable. To increase the ratio ``max_page_sharing`` must
 be increased accordingly.
 
-The ``stable_node_dups/stable_node_chains`` ratio is also affected by the
-``max_page_sharing`` tunable, and an high ratio may indicate fragmentation
-in the stable_node dups, which could be solved by introducing
-fragmentation algorithms in ksmd which would refile rmap_items from
-one stable_node dup to another stable_node dup, in order to free up
-stable_node "dups" with few rmap_items in them, but that may increase
-the ksmd CPU usage and possibly slowdown the readonly computations on
-the KSM pages of the applications.
-
 Design
 ======
 
@@ -247,6 +237,15 @@ deduplication factor at the expense of slower worst case for rmap
 walks for any KSM page which can happen during swapping, compaction,
 NUMA balancing and page migration.
 
+The ``stable_node_dups/stable_node_chains`` ratio is also affected by the
+``max_page_sharing`` tunable, and an high ratio may indicate fragmentation
+in the stable_node dups, which could be solved by introducing
+fragmentation algorithms in ksmd which would refile rmap_items from
+one stable_node dup to another stable_node dup, in order to free up
+stable_node "dups" with few rmap_items in them, but that may increase
+the ksmd CPU usage and possibly slowdown the readonly computations on
+the KSM pages of the applications.
+
 The whole list of stable_node "dups" linked in the stable_node
 "chains" is scanned periodically in order to prune stale stable_nodes.
 The frequency of such scans is defined by
-- 
2.7.4
