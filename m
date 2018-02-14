Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40B546B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 20:00:54 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m70so5200516ioi.8
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 17:00:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j19sor1799972iod.53.2018.02.13.17.00.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Feb 2018 17:00:53 -0800 (PST)
Date: Tue, 13 Feb 2018 17:00:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, page_alloc: extend kernelcore and movablecore for
 percent fix
In-Reply-To: <alpine.DEB.2.10.1802131651140.69963@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1802131700160.71590@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com> <a064d937-5746-3e14-bb63-5ff9d845a428@oracle.com> <alpine.DEB.2.10.1802131651140.69963@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

Specify that movablecore= can use a percent value.

Remove comment about hugetlb pages not being movable per Mike.

Cc: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 .../admin-guide/kernel-parameters.txt         | 22 +++++++++----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -1837,10 +1837,9 @@
 
 			ZONE_MOVABLE is used for the allocation of pages that
 			may be reclaimed or moved by the page migration
-			subsystem.  This means that HugeTLB pages may not be
-			allocated from this zone.  Note that allocations like
-			PTEs-from-HighMem still use the HighMem zone if it
-			exists, and the Normal zone if it does not.
+			subsystem.  Note that allocations like PTEs-from-HighMem
+			still use the HighMem zone if it exists, and the Normal
+			zone if it does not.
 
 			It is possible to specify the exact amount of memory in
 			the form of "nn[KMGTPE]", a percentage of total system
@@ -2353,13 +2352,14 @@
 	mousedev.yres=	[MOUSE] Vertical screen resolution, used for devices
 			reporting absolute coordinates, such as tablets
 
-	movablecore=nn[KMG]	[KNL,X86,IA-64,PPC] This parameter
-			is similar to kernelcore except it specifies the
-			amount of memory used for migratable allocations.
-			If both kernelcore and movablecore is specified,
-			then kernelcore will be at *least* the specified
-			value but may be more. If movablecore on its own
-			is specified, the administrator must be careful
+	movablecore=	[KNL,X86,IA-64,PPC]
+			Format: nn[KMGTPE] | nn%
+			This parameter is the complement to kernelcore=, it
+			specifies the amount of memory used for migratable
+			allocations.  If both kernelcore and movablecore is
+			specified, then kernelcore will be at *least* the
+			specified value but may be more.  If movablecore on its
+			own is specified, the administrator must be careful
 			that the amount of memory usable for all allocations
 			is not too small.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
