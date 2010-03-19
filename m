Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B31036B01B7
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 14:51:24 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 19 Mar 2010 15:00:10 -0400
Message-Id: <20100319190010.21430.41771.sendpatchset@localhost.localdomain>
In-Reply-To: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
References: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
Subject: [PATCH 6/6] Mempolicy: document cpuset interaction with tmpfs mpol mount option
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Update Documentation/filesystems/tmpfs.txt to describe the
interaction of tmpfs mount option memory policy with tasks'
cpuset mems_allowed.

Note:  the mount(8) man page [in the util-linux-ng package]
requires similiar updates.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/filesystems/tmpfs.txt |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

Index: linux-2.6.34-rc1-mmotm-100311-1313/Documentation/filesystems/tmpfs.txt
===================================================================
--- linux-2.6.34-rc1-mmotm-100311-1313.orig/Documentation/filesystems/tmpfs.txt	2010-03-19 09:06:15.000000000 -0400
+++ linux-2.6.34-rc1-mmotm-100311-1313/Documentation/filesystems/tmpfs.txt	2010-03-19 11:22:37.000000000 -0400
@@ -94,11 +94,19 @@ NodeList format is a comma-separated lis
 a range being two hyphen-separated decimal numbers, the smallest and
 largest node numbers in the range.  For example, mpol=bind:0-3,5,7,9-15
 
+A memory policy with a valid NodeList will be saved, as specified, for
+use at file creation time.  When a task allocates a file in the file
+system, the mount option memory policy will be applied with a NodeList,
+if any, modified by the calling task's cpuset constraints
+[See Documentation/cgroups/cpusets.txt] and any optional flags, listed
+below.  If the resulting NodeLists is the empty set, the effective memory
+policy for the file will revert to "default" policy.
+
 NUMA memory allocation policies have optional flags that can be used in
 conjunction with their modes.  These optional flags can be specified
 when tmpfs is mounted by appending them to the mode before the NodeList.
 See Documentation/vm/numa_memory_policy.txt for a list of all available
-memory allocation policy mode flags.
+memory allocation policy mode flags and their effect on memory policy.
 
 	=static		is equivalent to	MPOL_F_STATIC_NODES
 	=relative	is equivalent to	MPOL_F_RELATIVE_NODES

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
