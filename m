Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABD36B006C
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:31:19 -0500 (EST)
Received: by paceu11 with SMTP id eu11so12251042pac.7
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 00:31:19 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id pl9si210201pdb.47.2015.02.26.00.31.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 26 Feb 2015 00:31:18 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] cma: debug: document new debugfs interface
Date: Thu, 26 Feb 2015 03:31:03 -0500
Message-Id: <1424939463-18119-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

Document the structure and files under the new debugfs interface.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 Documentation/cma/debugfs.txt |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)
 create mode 100644 Documentation/cma/debugfs.txt

diff --git a/Documentation/cma/debugfs.txt b/Documentation/cma/debugfs.txt
new file mode 100644
index 0000000..6cef20a
--- /dev/null
+++ b/Documentation/cma/debugfs.txt
@@ -0,0 +1,21 @@
+The CMA debugfs interface is useful to retrieve basic information out of the
+different CMA areas and to test allocation/release in each of the areas.
+
+Each CMA zone represents a directory under <debugfs>/cma/, indexed by the
+kernel's CMA index. So the first CMA zone would be:
+
+	<debugfs>/cma/cma-0
+
+The structure of the files created under that directory is as follows:
+
+ - [RO] base_pfn: The base PFN (Page Frame Number) of the zone.
+ - [RO] count: Amount of memory in the CMA area.
+ - [RO] order_per_bit: Order of pages represented by one bit.
+ - [RO] bitmap: The bitmap of page states in the zone.
+ - [WO] alloc: Allocate N pages from that CMA area. For example:
+
+	echo 5 > <debugfs>/cma/cma-2/alloc
+
+would try to allocate 5 pages from the cma-2 area.
+
+ - [WO] free: Free N pages from that CMA area, similar to the above.
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
