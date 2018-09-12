Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38B828E0007
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:25:06 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x204-v6so2861118qka.6
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:25:06 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q8-v6si1456450qvh.274.2018.09.12.13.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 13:25:05 -0700 (PDT)
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Subject: [PATCH V2 6/6] /proc/pid/numa_vamaps: document in Documentation/filesystems/proc.txt
Date: Wed, 12 Sep 2018 13:24:04 -0700
Message-Id: <1536783844-4145-7-git-send-email-prakash.sangappa@oracle.com>
In-Reply-To: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: dave.hansen@intel.com, mhocko@suse.com, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com, steven.sistare@oracle.com, prakash.sangappa@oracle.com

Add documentation for /proc/<pid>/numa_vamaps in
Documentation/filesystems/proc.txt

Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
---
 Documentation/filesystems/proc.txt | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 22b4b00..7095216 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -150,6 +150,9 @@ Table 1-1: Process specific entries in /proc
 		each mapping and flags associated with it
  numa_maps	an extension based on maps, showing the memory locality and
 		binding policy as well as mem usage (in pages) of each mapping.
+ numa_vamaps	Presents information about mapped address ranges to numa node
+		from where the physical memory is allocated.
+
 ..............................................................................
 
 For example, to get the status information of a process, all you have to do is
@@ -571,6 +574,24 @@ Where:
 node locality page counters (N0 == node0, N1 == node1, ...) and the kernel page
 size, in KB, that is backing the mapping up.
 
+The /proc/pid/numa_vamaps shows mapped address ranges to numa node id from
+where the physical pages are allocated. For mapped address ranges not having
+any pages mapped a '-' is shown instead of the node id. Each line in the file
+will show address range to one numa node.
+
+address-range	numa-node-id
+
+00400000-00410000 N1
+00410000-0047f000 N0
+0047f000-00480000 N2
+00480000-00481000 -
+00481000-004a0000 N0
+004a0000-004a2000 -
+004a2000-004aa000 N2
+004aa000-004ad000 N0
+004ad000-004ae000 -
+..
+
 1.2 Kernel data
 ---------------
 
-- 
2.7.4
