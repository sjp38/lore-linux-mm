Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5329C6B026B
	for <linux-mm@kvack.org>; Tue,  8 May 2018 03:02:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y6-v6so20998768wrm.10
        for <linux-mm@kvack.org>; Tue, 08 May 2018 00:02:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s19-v6si1798724eda.85.2018.05.08.00.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 00:02:28 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w486xCJ0070594
	for <linux-mm@kvack.org>; Tue, 8 May 2018 03:02:27 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hu2bhagbt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 May 2018 03:02:27 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 8 May 2018 08:02:25 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/3] docs/vm: move numa_memory_policy.rst to Documentation/admin-guide/mm
Date: Tue,  8 May 2018 10:02:10 +0300
In-Reply-To: <1525762930-28163-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1525762930-28163-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1525762930-28163-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The document describes userspace API and as such it belongs to
Documentation/admin-guide/mm

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/admin-guide/mm/hugetlbpage.rst                | 2 +-
 Documentation/admin-guide/mm/index.rst                      | 1 +
 Documentation/{vm => admin-guide/mm}/numa_memory_policy.rst | 0
 Documentation/filesystems/proc.txt                          | 2 +-
 Documentation/filesystems/tmpfs.txt                         | 5 +++--
 Documentation/vm/00-INDEX                                   | 2 --
 Documentation/vm/index.rst                                  | 1 -
 Documentation/vm/numa.rst                                   | 2 +-
 8 files changed, 7 insertions(+), 8 deletions(-)
 rename Documentation/{vm => admin-guide/mm}/numa_memory_policy.rst (100%)

diff --git a/Documentation/admin-guide/mm/hugetlbpage.rst b/Documentation/admin-guide/mm/hugetlbpage.rst
index a8b0806..1cc0bc7 100644
--- a/Documentation/admin-guide/mm/hugetlbpage.rst
+++ b/Documentation/admin-guide/mm/hugetlbpage.rst
@@ -220,7 +220,7 @@ memory policy mode--bind, preferred, local or interleave--may be used.  The
 resulting effect on persistent huge page allocation is as follows:
 
 #. Regardless of mempolicy mode [see
-   :ref:`Documentation/vm/numa_memory_policy.rst <numa_memory_policy>`],
+   :ref:`Documentation/admin-guide/mm/numa_memory_policy.rst <numa_memory_policy>`],
    persistent huge pages will be distributed across the node or nodes
    specified in the mempolicy as if "interleave" had been specified.
    However, if a node in the policy does not contain sufficient contiguous
diff --git a/Documentation/admin-guide/mm/index.rst b/Documentation/admin-guide/mm/index.rst
index ad28644..a69aa69 100644
--- a/Documentation/admin-guide/mm/index.rst
+++ b/Documentation/admin-guide/mm/index.rst
@@ -24,6 +24,7 @@ the Linux memory management.
    hugetlbpage
    idle_page_tracking
    ksm
+   numa_memory_policy
    pagemap
    soft-dirty
    userfaultfd
diff --git a/Documentation/vm/numa_memory_policy.rst b/Documentation/admin-guide/mm/numa_memory_policy.rst
similarity index 100%
rename from Documentation/vm/numa_memory_policy.rst
rename to Documentation/admin-guide/mm/numa_memory_policy.rst
diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index ef53f80..520f6a8 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -566,7 +566,7 @@ address   policy    mapping details
 
 Where:
 "address" is the starting address for the mapping;
-"policy" reports the NUMA memory policy set for the mapping (see vm/numa_memory_policy.txt);
+"policy" reports the NUMA memory policy set for the mapping (see Documentation/admin-guide/mm/numa_memory_policy.rst);
 "mapping details" summarizes mapping data such as mapping type, page usage counters,
 node locality page counters (N0 == node0, N1 == node1, ...) and the kernel page
 size, in KB, that is backing the mapping up.
diff --git a/Documentation/filesystems/tmpfs.txt b/Documentation/filesystems/tmpfs.txt
index 627389a..d06e9a5 100644
--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -105,8 +105,9 @@ policy for the file will revert to "default" policy.
 NUMA memory allocation policies have optional flags that can be used in
 conjunction with their modes.  These optional flags can be specified
 when tmpfs is mounted by appending them to the mode before the NodeList.
-See Documentation/vm/numa_memory_policy.rst for a list of all available
-memory allocation policy mode flags and their effect on memory policy.
+See Documentation/admin-guide/mm/numa_memory_policy.rst for a list of
+all available memory allocation policy mode flags and their effect on
+memory policy.
 
 	=static		is equivalent to	MPOL_F_STATIC_NODES
 	=relative	is equivalent to	MPOL_F_RELATIVE_NODES
diff --git a/Documentation/vm/00-INDEX b/Documentation/vm/00-INDEX
index f8a96ca..f4a4f3e 100644
--- a/Documentation/vm/00-INDEX
+++ b/Documentation/vm/00-INDEX
@@ -22,8 +22,6 @@ mmu_notifier.rst
 	- a note about clearing pte/pmd and mmu notifications
 numa.rst
 	- information about NUMA specific code in the Linux vm.
-numa_memory_policy.rst
-	- documentation of concepts and APIs of the 2.6 memory policy support.
 overcommit-accounting.rst
 	- description of the Linux kernels overcommit handling modes.
 page_frags.rst
diff --git a/Documentation/vm/index.rst b/Documentation/vm/index.rst
index ed58cb9..8e1cc66 100644
--- a/Documentation/vm/index.rst
+++ b/Documentation/vm/index.rst
@@ -14,7 +14,6 @@ various features of the Linux memory management
    :maxdepth: 1
 
    ksm
-   numa_memory_policy
    transhuge
    swap_numa
    zswap
diff --git a/Documentation/vm/numa.rst b/Documentation/vm/numa.rst
index aada84b..185d8a5 100644
--- a/Documentation/vm/numa.rst
+++ b/Documentation/vm/numa.rst
@@ -110,7 +110,7 @@ to improve NUMA locality using various CPU affinity command line interfaces,
 such as taskset(1) and numactl(1), and program interfaces such as
 sched_setaffinity(2).  Further, one can modify the kernel's default local
 allocation behavior using Linux NUMA memory policy.
-[see Documentation/vm/numa_memory_policy.rst.]
+[see Documentation/admin-guide/mm/numa_memory_policy.rst.]
 
 System administrators can restrict the CPUs and nodes' memories that a non-
 privileged user can specify in the scheduling or NUMA commands and functions
-- 
2.7.4
