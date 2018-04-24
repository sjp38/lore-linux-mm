Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 641B66B0009
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:50 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p190so7783443qkc.17
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:40:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m21-v6si12928374qtf.343.2018.04.23.23.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:40:49 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3O6emum054701
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:48 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hhw8tnvhk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:48 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Apr 2018 07:40:45 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 5/7] docs/vm: ksm: update stable_node_chains_prune_millisecs description
Date: Tue, 24 Apr 2018 09:40:26 +0300
In-Reply-To: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524552028-7017-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Make the description of stable_node_chains_prune_millisecs sysfs parameter
less implementation aware and add a few words about this parameter in the
"Design" section.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/ksm.rst | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/Documentation/vm/ksm.rst b/Documentation/vm/ksm.rst
index 00961b8..18d7c71 100644
--- a/Documentation/vm/ksm.rst
+++ b/Documentation/vm/ksm.rst
@@ -150,14 +150,12 @@ max_page_sharing
         traversals are always schedule friendly themselves.
 
 stable_node_chains_prune_millisecs
-        How frequently to walk the whole list of stable_node "dups"
-        linked in the stable_node "chains" in order to prune stale
-        stable_nodes. Smaller milllisecs values will free up the KSM
-        metadata with lower latency, but they will make ksmd use more
-        CPU during the scan. This only applies to the stable_node
-        chains so it's a noop if not a single KSM page hit the
-        ``max_page_sharing`` yet (there would be no stable_node chains in
-        such case).
+        specifies how frequently KSM checks the metadata of the pages
+        that hit the deduplication limit for stale information.
+        Smaller milllisecs values will free up the KSM metadata with
+        lower latency, but they will make ksmd use more CPU during the
+        scan. It's a noop if not a single KSM page hit the
+        ``max_page_sharing`` yet.
 
 The effectiveness of KSM and MADV_MERGEABLE is shown in ``/sys/kernel/mm/ksm/``:
 
@@ -249,6 +247,11 @@ deduplication factor at the expense of slower worst case for rmap
 walks for any KSM page which can happen during swapping, compaction,
 NUMA balancing and page migration.
 
+The whole list of stable_node "dups" linked in the stable_node
+"chains" is scanned periodically in order to prune stale stable_nodes.
+The frequency of such scans is defined by
+``stable_node_chains_prune_millisecs`` sysfs tunable.
+
 Reference
 ---------
 .. kernel-doc:: mm/ksm.c
-- 
2.7.4
