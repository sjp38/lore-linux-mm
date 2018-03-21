Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C4D886B002D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v6so2973795wrg.8
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:23:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x19si2878edb.73.2018.03.21.12.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:23:47 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJIZSx094259
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:46 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2guvmsafs3-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:45 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:23:43 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 09/32] docs/vm: hwpoison.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:25 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-10-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/hwpoison.txt | 141 +++++++++++++++++++++---------------------
 1 file changed, 70 insertions(+), 71 deletions(-)

diff --git a/Documentation/vm/hwpoison.txt b/Documentation/vm/hwpoison.txt
index e912d7e..b1a8c24 100644
--- a/Documentation/vm/hwpoison.txt
+++ b/Documentation/vm/hwpoison.txt
@@ -1,7 +1,14 @@
+.. hwpoison:
+
+========
+hwpoison
+========
+
 What is hwpoison?
+=================
 
 Upcoming Intel CPUs have support for recovering from some memory errors
-(``MCA recovery''). This requires the OS to declare a page "poisoned",
+(``MCA recovery``). This requires the OS to declare a page "poisoned",
 kill the processes associated with it and avoid using it in the future.
 
 This patchkit implements the necessary infrastructure in the VM.
@@ -46,9 +53,10 @@ address. This in theory allows other applications to handle
 memory failures too. The expection is that near all applications
 won't do that, but some very specialized ones might.
 
----
+Failure recovery modes
+======================
 
-There are two (actually three) modi memory failure recovery can be in:
+There are two (actually three) modes memory failure recovery can be in:
 
 vm.memory_failure_recovery sysctl set to zero:
 	All memory failures cause a panic. Do not attempt recovery.
@@ -67,9 +75,8 @@ late kill
 	This is best for memory error unaware applications and default
 	Note some pages are always handled as late kill.
 
----
-
-User control:
+User control
+============
 
 vm.memory_failure_recovery
 	See sysctl.txt
@@ -79,11 +86,19 @@ vm.memory_failure_early_kill
 
 PR_MCE_KILL
 	Set early/late kill mode/revert to system default
-	arg1: PR_MCE_KILL_CLEAR: Revert to system default
-	arg1: PR_MCE_KILL_SET: arg2 defines thread specific mode
-		PR_MCE_KILL_EARLY: Early kill
-		PR_MCE_KILL_LATE:  Late kill
-		PR_MCE_KILL_DEFAULT: Use system global default
+
+	arg1: PR_MCE_KILL_CLEAR:
+		Revert to system default
+	arg1: PR_MCE_KILL_SET:
+		arg2 defines thread specific mode
+
+		PR_MCE_KILL_EARLY:
+			Early kill
+		PR_MCE_KILL_LATE:
+			Late kill
+		PR_MCE_KILL_DEFAULT
+			Use system global default
+
 	Note that if you want to have a dedicated thread which handles
 	the SIGBUS(BUS_MCEERR_AO) on behalf of the process, you should
 	call prctl(PR_MCE_KILL_EARLY) on the designated thread. Otherwise,
@@ -92,77 +107,64 @@ PR_MCE_KILL
 PR_MCE_KILL_GET
 	return current mode
 
+Testing
+=======
 
----
-
-Testing:
-
-madvise(MADV_HWPOISON, ....)
-	(as root)
-	Poison a page in the process for testing
-
+* madvise(MADV_HWPOISON, ....) (as root) - Poison a page in the
+  process for testing
 
-hwpoison-inject module through debugfs
+* hwpoison-inject module through debugfs ``/sys/kernel/debug/hwpoison/``
 
-/sys/kernel/debug/hwpoison/
+  corrupt-pfn
+	Inject hwpoison fault at PFN echoed into this file. This does
+	some early filtering to avoid corrupted unintended pages in test suites.
 
-corrupt-pfn
+  unpoison-pfn
+	Software-unpoison page at PFN echoed into this file. This way
+	a page can be reused again.  This only works for Linux
+	injected failures, not for real memory failures.
 
-Inject hwpoison fault at PFN echoed into this file. This does
-some early filtering to avoid corrupted unintended pages in test suites.
+  Note these injection interfaces are not stable and might change between
+  kernel versions
 
-unpoison-pfn
+  corrupt-filter-dev-major, corrupt-filter-dev-minor
+	Only handle memory failures to pages associated with the file
+	system defined by block device major/minor.  -1U is the
+	wildcard value.  This should be only used for testing with
+	artificial injection.
 
-Software-unpoison page at PFN echoed into this file. This
-way a page can be reused again.
-This only works for Linux injected failures, not for real
-memory failures.
+  corrupt-filter-memcg
+	Limit injection to pages owned by memgroup. Specified by inode
+	number of the memcg.
 
-Note these injection interfaces are not stable and might change between
-kernel versions
+	Example::
 
-corrupt-filter-dev-major
-corrupt-filter-dev-minor
+		mkdir /sys/fs/cgroup/mem/hwpoison
 
-Only handle memory failures to pages associated with the file system defined
-by block device major/minor.  -1U is the wildcard value.
-This should be only used for testing with artificial injection.
+	        usemem -m 100 -s 1000 &
+		echo `jobs -p` > /sys/fs/cgroup/mem/hwpoison/tasks
 
-corrupt-filter-memcg
+		memcg_ino=$(ls -id /sys/fs/cgroup/mem/hwpoison | cut -f1 -d' ')
+		echo $memcg_ino > /debug/hwpoison/corrupt-filter-memcg
 
-Limit injection to pages owned by memgroup. Specified by inode number
-of the memcg.
+		page-types -p `pidof init`   --hwpoison  # shall do nothing
+		page-types -p `pidof usemem` --hwpoison  # poison its pages
 
-Example:
-        mkdir /sys/fs/cgroup/mem/hwpoison
+  corrupt-filter-flags-mask, corrupt-filter-flags-value
+	When specified, only poison pages if ((page_flags & mask) ==
+	value).  This allows stress testing of many kinds of
+	pages. The page_flags are the same as in /proc/kpageflags. The
+	flag bits are defined in include/linux/kernel-page-flags.h and
+	documented in Documentation/vm/pagemap.txt
 
-        usemem -m 100 -s 1000 &
-        echo `jobs -p` > /sys/fs/cgroup/mem/hwpoison/tasks
+* Architecture specific MCE injector
 
-        memcg_ino=$(ls -id /sys/fs/cgroup/mem/hwpoison | cut -f1 -d' ')
-        echo $memcg_ino > /debug/hwpoison/corrupt-filter-memcg
+  x86 has mce-inject, mce-test
 
-        page-types -p `pidof init`   --hwpoison  # shall do nothing
-        page-types -p `pidof usemem` --hwpoison  # poison its pages
+  Some portable hwpoison test programs in mce-test, see below.
 
-corrupt-filter-flags-mask
-corrupt-filter-flags-value
-
-When specified, only poison pages if ((page_flags & mask) == value).
-This allows stress testing of many kinds of pages. The page_flags
-are the same as in /proc/kpageflags. The flag bits are defined in
-include/linux/kernel-page-flags.h and documented in
-Documentation/vm/pagemap.txt
-
-Architecture specific MCE injector
-
-x86 has mce-inject, mce-test
-
-Some portable hwpoison test programs in mce-test, see blow.
-
----
-
-References:
+References
+==========
 
 http://halobates.de/mce-lc09-2.pdf
 	Overview presentation from LinuxCon 09
@@ -174,14 +176,11 @@ git://git.kernel.org/pub/scm/utils/cpu/mce/mce-inject.git
 	x86 specific injector
 
 
----
-
-Limitations:
-
+Limitations
+===========
 - Not all page types are supported and never will. Most kernel internal
-objects cannot be recovered, only LRU pages for now.
+  objects cannot be recovered, only LRU pages for now.
 - Right now hugepage support is missing.
 
 ---
 Andi Kleen, Oct 2009
-
-- 
2.7.4
