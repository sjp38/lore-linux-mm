Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3BNdBSF026689
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 19:39:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3BNdBPA261748
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 19:39:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3BNdBt1017545
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 19:39:11 -0400
Date: Fri, 11 Apr 2008 16:39:19 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] Documentation: correct overcommit caveat in hugetlbpage.txt
Message-ID: <20080411233919.GD19078@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: gurudas.pai@oracle.com, apw@shadowen.org, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As shown by Gurudas Pai recently, we can put hugepages into the surplus
state (by echo 0 > /proc/sys/vm/nr_hugepages), even when
/proc/sys/vm/nr_overcommit_hugepages is 0. This is actually correct, to
allow the original goal (shrink the static pool to 0) to succeed (we are
converting hugepages to surplus because they are in use). However, the
documentation does not accurately reflect this case. Update it.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Andy Whitcroft <apw@shadowen.org>

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index f962d01..3102b81 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -88,10 +88,9 @@ hugepages from the buddy allocator, if the normal pool is exhausted. As
 these surplus hugepages go out of use, they are freed back to the buddy
 allocator.
 
-Caveat: Shrinking the pool via nr_hugepages while a surplus is in effect
-will allow the number of surplus huge pages to exceed the overcommit
-value, as the pool hugepages (which must have been in use for a surplus
-hugepages to be allocated) will become surplus hugepages.  As long as
+Caveat: Shrinking the pool via nr_hugepages such that it becomes less
+than the number of hugepages in use will convert the balance to surplus
+huge pages even if it would exceed the overcommit value.  As long as
 this condition holds, however, no more surplus huge pages will be
 allowed on the system until one of the two sysctls are increased
 sufficiently, or the surplus huge pages go out of use and are freed.

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
