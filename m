Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3BNo109028912
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 19:50:01 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3BNo0Dm189920
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:50:00 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3BNo0lY010966
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:50:00 -0600
Date: Fri, 11 Apr 2008 16:50:08 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [RFC][PATCH 5/5] Documentation: update ABI and hugetlbpage.txt for
	per-node files
Message-ID: <20080411235008.GI19078@us.ibm.com>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080411234913.GH19078@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: clameter@sgi.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org, npiggin@suse.de, gregkh@suse.de
List-ID: <linux-mm.kvack.org>

---
This patch will change if we decide to move the per-node interface to
another location in sysfs.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

diff --git a/Documentation/ABI/testing/sysfs-devices-system-node b/Documentation/ABI/testing/sysfs-devices-system-node
index 97d6145..5766902 100644
--- a/Documentation/ABI/testing/sysfs-devices-system-node
+++ b/Documentation/ABI/testing/sysfs-devices-system-node
@@ -57,3 +57,10 @@ Description:
 		NUMA statistics for <node>.
 		NOTE: This file violates the sysfs rules for one value
 		per file.
+
+What:		/sys/devices/system/node/<node>/nr_hugepages
+Date:		April 2008
+Contact:	Nish Aravamudan <nacc@us.ibm.com>
+Description:
+		Interface to allocate (and check) hugepages on <node>.
+		This file will not exist if CONFIG_HUGETLB_PAGE is off.
diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index 3102b81..b749607 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -80,6 +80,13 @@ of getting physical contiguous pages is still very high). In either
 case, adminstrators will want to verify the number of hugepages actually
 allocated by checking the sysctl or meminfo.
 
+/sys/devices/system/node/nodeX/nr_hugepages allows for finer-grained
+control of the hugepage pool on NUMA machines. The functionality is the
+same as for nr_hugepages, but the effects are restricted to the node in
+question. Similarly, administrators will want to verify the number of
+hugepages actually allocated or freed by checking the per-node meminfo
+or nr_hugepages file.
+
 /proc/sys/vm/nr_overcommit_hugepages indicates how large the pool of
 hugepages can grow, if more hugepages than /proc/sys/vm/nr_hugepages are
 requested by applications. echo'ing any non-zero value into this file

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
