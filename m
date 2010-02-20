Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D5CB06B0078
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 04:41:27 -0500 (EST)
Date: Sat, 20 Feb 2010 09:41:09 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] mm: Document /sys/devices/system/node/nodeX
Message-ID: <20100220094109.GJ1445@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add a bare description of what /sys/devices/system/node/nodeX is. Others
will follow in time but right now, none of that tree is documented. The
existence of this file might at least encourage people to document new entries.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 Documentation/ABI/stable/sysfs-devices-node |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/stable/sysfs-devices-node

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
new file mode 100644
index 0000000..49b82ca
--- /dev/null
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -0,0 +1,7 @@
+What:		/sys/devices/system/node/nodeX
+Date:		October 2002
+Contact:	Linux Memory Management list <linux-mm@kvack.org>
+Description:
+		When CONFIG_NUMA is enabled, this is a directory containing
+		information on node X such as what CPUs are local to the
+		node.
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
