Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C8798D0002
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 19:19:08 -0400 (EDT)
Received: from chimera.site ([173.50.240.230]) by xenotime.net for <linux-mm@kvack.org>; Mon, 25 Oct 2010 16:18:58 -0700
Date: Mon, 25 Oct 2010 16:18:58 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] Fix typos in Documentation/sysctl/vm.txt
Message-Id: <20101025161858.fb2e8353.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm <akpm@linux-foundation.org>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Please merge this (unless someone sees problems with it).
Looks good to me.

Acked-by: Randy Dunlap <rdunlap@xenotime.net>
---

Date: Mon, 18 Oct 2010 11:06:54 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
To: linux-doc@vger.kernel.org
Cc: rdunlap@xenotime.net, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
Subject: [PATCH] Fix typos in Documentation/sysctl/vm.txt


 Fix couple of typos in Documentation/sysctl/vm.txt under
numa_zonelist_order.

Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
--
 Documentation/sysctl/vm.txt |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index b606c2c..4de9d5b 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -477,12 +477,12 @@ the DMA zone.
 Type(A) is called as "Node" order. Type (B) is "Zone" order.
 
 "Node order" orders the zonelists by node, then by zone within each node.
-Specify "[Nn]ode" for zone order
+Specify "[Nn]ode" for node order.
 
 "Zone Order" orders the zonelists by zone type, then by node within each
-zone.  Specify "[Zz]one"for zode order.
+zone.  Specify "[Zz]one" for zone order.
 
-Specify "[Dd]efault" to request automatic configuration.  Autoconfiguration
+Specify "[Dd]efault" to request automatic configuration. Autoconfiguration
 will select "node" order in following case.
 (1) if the DMA zone does not exist or
 (2) if the DMA zone comprises greater than 50% of the available memory or
			
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
