Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id CBF676B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 15:45:02 -0400 (EDT)
Message-ID: <1376423094.32758.1.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH] hugepage: mention libhugetlbfs in doc
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 13 Aug 2013 12:44:54 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, davidlohr@hp.com

From: Davidlohr Bueso <davidlohr@hp.com>

Explicitly mention/recommend using the libhugetlbfs test cases
when changing related kernel code. Developers that are unaware
of the project can easily miss this and introduce potential
regressions that may or may not be caught by community review.

Also do some cleanups that make the document visually easier to
view at a first glance.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 Documentation/vm/hugetlbpage.txt | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index 4ac359b..bdd4bb9 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -165,6 +165,7 @@ which function as described above for the default huge page-sized case.
 
 
 Interaction of Task Memory Policy with Huge Page Allocation/Freeing
+===================================================================
 
 Whether huge pages are allocated and freed via the /proc interface or
 the /sysfs interface using the nr_hugepages_mempolicy attribute, the NUMA
@@ -229,6 +230,7 @@ resulting effect on persistent huge page allocation is as follows:
    of huge pages over all on-lines nodes with memory.
 
 Per Node Hugepages Attributes
+=============================
 
 A subset of the contents of the root huge page control directory in sysfs,
 described above, will be replicated under each the system device of each
@@ -258,6 +260,7 @@ applied, from which node the huge page allocation will be attempted.
 
 
 Using Huge Pages
+================
 
 If the user applications are going to request huge pages using mmap system
 call, then it is required that system administrator mount a file system of
@@ -296,20 +299,16 @@ calls, though the mount of filesystem will be required for using mmap calls
 without MAP_HUGETLB.  For an example of how to use mmap with MAP_HUGETLB see
 map_hugetlb.c.
 
-*******************************************************************
+Examples
+========
 
-/*
- * map_hugetlb: see tools/testing/selftests/vm/map_hugetlb.c
- */
+1) map_hugetlb: see tools/testing/selftests/vm/map_hugetlb.c
 
-*******************************************************************
+2) hugepage-shm:  see tools/testing/selftests/vm/hugepage-shm.c
 
-/*
- * hugepage-shm:  see tools/testing/selftests/vm/hugepage-shm.c
- */
+3) hugepage-mmap:  see tools/testing/selftests/vm/hugepage-mmap.c
 
-*******************************************************************
-
-/*
- * hugepage-mmap:  see tools/testing/selftests/vm/hugepage-mmap.c
- */
+4) The libhugetlbfs (http://libhugetlbfs.sourceforge.net) library provides a
+   wide range of userspace tools to help with huge page usability, environment
+   setup, and control. Furthermore it provides useful test cases that should be
+   used when modifying code to ensure no regressions are introduced.
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
