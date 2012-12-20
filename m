Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 96AA16B0068
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 14:44:01 -0500 (EST)
Message-ID: <1356032637.24462.4.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH] Documentation: ABI: remove testing/sysfs-devices-node
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Thu, 20 Dec 2012 11:43:57 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

This file is already documented in the stable ABI (commit 5bbe1ec1).

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 Documentation/ABI/testing/sysfs-devices-node | 7 -------
 1 file changed, 7 deletions(-)
 delete mode 100644 Documentation/ABI/testing/sysfs-devices-node

diff --git a/Documentation/ABI/testing/sysfs-devices-node b/Documentation/ABI/testing/sysfs-devices-node
deleted file mode 100644
index 453a210..0000000
--- a/Documentation/ABI/testing/sysfs-devices-node
+++ /dev/null
@@ -1,7 +0,0 @@
-What:		/sys/devices/system/node/nodeX/compact
-Date:		February 2010
-Contact:	Mel Gorman <mel@csn.ul.ie>
-Description:
-		When this file is written to, all memory within that node
-		will be compacted. When it completes, memory will be freed
-		into blocks which have as many contiguous pages as possible
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
