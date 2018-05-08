Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 525F86B000D
	for <linux-mm@kvack.org>; Tue,  8 May 2018 03:02:25 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b83so3065844wme.7
        for <linux-mm@kvack.org>; Tue, 08 May 2018 00:02:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s3-v6si3519017edc.383.2018.05.08.00.02.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 00:02:23 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w486wlDf014782
	for <linux-mm@kvack.org>; Tue, 8 May 2018 03:02:22 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hu6kwsf0t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 May 2018 03:02:22 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 8 May 2018 08:02:20 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/3] docs/vm: numa_memory_policy: formatting and spelling updates
Date: Tue,  8 May 2018 10:02:08 +0300
In-Reply-To: <1525762930-28163-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1525762930-28163-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1525762930-28163-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/numa_memory_policy.rst | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/Documentation/vm/numa_memory_policy.rst b/Documentation/vm/numa_memory_policy.rst
index 8cd942c..ac0b396 100644
--- a/Documentation/vm/numa_memory_policy.rst
+++ b/Documentation/vm/numa_memory_policy.rst
@@ -44,14 +44,20 @@ System Default Policy
 	allocations.
 
 Task/Process Policy
-	this is an optional, per-task policy.  When defined for a specific task, this policy controls all page allocations made by or on behalf of the task that aren't controlled by a more specific scope. If a task does not define a task policy, then all page allocations that would have been controlled by the task policy "fall back" to the System Default Policy.
+	this is an optional, per-task policy.  When defined for a
+	specific task, this policy controls all page allocations made
+	by or on behalf of the task that aren't controlled by a more
+	specific scope. If a task does not define a task policy, then
+	all page allocations that would have been controlled by the
+	task policy "fall back" to the System Default Policy.
 
 	The task policy applies to the entire address space of a task. Thus,
 	it is inheritable, and indeed is inherited, across both fork()
 	[clone() w/o the CLONE_VM flag] and exec*().  This allows a parent task
 	to establish the task policy for a child task exec()'d from an
 	executable image that has no awareness of memory policy.  See the
-	MEMORY POLICY APIS section, below, for an overview of the system call
+	:ref:`Memory Policy APIs <memory_policy_apis>` section,
+	below, for an overview of the system call
 	that a task may use to set/change its task/process policy.
 
 	In a multi-threaded task, task policies apply only to the thread
@@ -70,12 +76,13 @@ Task/Process Policy
 VMA Policy
 	A "VMA" or "Virtual Memory Area" refers to a range of a task's
 	virtual address space.  A task may define a specific policy for a range
-	of its virtual address space.   See the MEMORY POLICIES APIS section,
+	of its virtual address space.   See the
+	:ref:`Memory Policy APIs <memory_policy_apis>` section,
 	below, for an overview of the mbind() system call used to set a VMA
 	policy.
 
 	A VMA policy will govern the allocation of pages that back
-	this region ofthe address space.  Any regions of the task's
+	this region of the address space.  Any regions of the task's
 	address space that don't have an explicit VMA policy will fall
 	back to the task policy, which may itself fall back to the
 	System Default Policy.
@@ -117,7 +124,7 @@ VMA Policy
 Shared Policy
 	Conceptually, shared policies apply to "memory objects" mapped
 	shared into one or more tasks' distinct address spaces.  An
-	application installs a shared policies the same way as VMA
+	application installs shared policies the same way as VMA
 	policies--using the mbind() system call specifying a range of
 	virtual addresses that map the shared object.  However, unlike
 	VMA policies, which can be considered to be an attribute of a
@@ -135,7 +142,7 @@ Shared Policy
 	Although hugetlbfs segments now support lazy allocation, their support
 	for shared policy has not been completed.
 
-	As mentioned above :ref:`VMA policies <vma_policy>`,
+	As mentioned above in :ref:`VMA policies <vma_policy>` section,
 	allocations of page cache pages for regular files mmap()ed
 	with MAP_SHARED ignore any VMA policy installed on the virtual
 	address range backed by the shared file mapping.  Rather,
@@ -245,7 +252,7 @@ MPOL_F_STATIC_NODES
 	the user should not be remapped if the task or VMA's set of allowed
 	nodes changes after the memory policy has been defined.
 
-	Without this flag, anytime a mempolicy is rebound because of a
+	Without this flag, any time a mempolicy is rebound because of a
 	change in the set of allowed nodes, the node (Preferred) or
 	nodemask (Bind, Interleave) is remapped to the new set of
 	allowed nodes.  This may result in nodes being used that were
@@ -389,7 +396,10 @@ follows:
    or by prefaulting the entire shared memory region into memory and locking
    it down.  However, this might not be appropriate for all applications.
 
+.. _memory_policy_apis:
+
 Memory Policy APIs
+==================
 
 Linux supports 3 system calls for controlling memory policy.  These APIS
 always affect only the calling task, the calling task's address space, or
-- 
2.7.4
