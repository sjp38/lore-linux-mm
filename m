Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAC66B0266
	for <linux-mm@kvack.org>; Tue,  8 May 2018 03:02:28 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id t24-v6so23340432qtn.7
        for <linux-mm@kvack.org>; Tue, 08 May 2018 00:02:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u5si371474qkh.146.2018.05.08.00.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 00:02:27 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w486ws5R040306
	for <linux-mm@kvack.org>; Tue, 8 May 2018 03:02:26 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hu6wf8m1r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 May 2018 03:02:26 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 8 May 2018 08:02:23 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/3] docs/vm: numa_memory_policy: s/Linux memory policy/NUMA memory policy/
Date: Tue,  8 May 2018 10:02:09 +0300
In-Reply-To: <1525762930-28163-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1525762930-28163-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1525762930-28163-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The document describes NUMA memory policy and as it is a part of the Linux
documentation it's obvious that this is Linux memory policy. Besides,
"Linux memory policy" may refer to other policies, e.g. memory hotplug
policy, and using term NUMA makes the documentation less ambiguous.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/numa_memory_policy.rst | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/Documentation/vm/numa_memory_policy.rst b/Documentation/vm/numa_memory_policy.rst
index ac0b396..d78c5b3 100644
--- a/Documentation/vm/numa_memory_policy.rst
+++ b/Documentation/vm/numa_memory_policy.rst
@@ -1,10 +1,10 @@
 .. _numa_memory_policy:
 
-===================
-Linux Memory Policy
-===================
+==================
+NUMA Memory Policy
+==================
 
-What is Linux Memory Policy?
+What is NUMA Memory Policy?
 ============================
 
 In the Linux kernel, "memory policy" determines from which node the kernel will
@@ -162,7 +162,7 @@ Shared Policy
 Components of Memory Policies
 -----------------------------
 
-A Linux memory policy consists of a "mode", optional mode flags, and
+A NUMA memory policy consists of a "mode", optional mode flags, and
 an optional set of nodes.  The mode determines the behavior of the
 policy, the optional mode flags determine the behavior of the mode,
 and the optional set of nodes can be viewed as the arguments to the
@@ -172,7 +172,7 @@ Internally, memory policies are implemented by a reference counted
 structure, struct mempolicy.  Details of this structure will be
 discussed in context, below, as required to explain the behavior.
 
-Linux memory policy supports the following 4 behavioral modes:
+NUMA memory policy supports the following 4 behavioral modes:
 
 Default Mode--MPOL_DEFAULT
 	This mode is only used in the memory policy APIs.  Internally,
@@ -245,7 +245,7 @@ MPOL_INTERLEAVED
 	address range or file.  During system boot up, the temporary
 	interleaved system default policy works in this mode.
 
-Linux memory policy supports the following optional mode flags:
+NUMA memory policy supports the following optional mode flags:
 
 MPOL_F_STATIC_NODES
 	This flag specifies that the nodemask passed by
-- 
2.7.4
