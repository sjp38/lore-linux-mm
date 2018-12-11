Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D53EB8E006E
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 20:05:48 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i3so11261070pfj.4
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 17:05:48 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si11402278pfj.276.2018.12.10.17.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 17:05:47 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 04/12] Documentation/ABI: Add new node sysfs attributes
Date: Mon, 10 Dec 2018 18:03:02 -0700
Message-Id: <20181211010310.8551-5-keith.busch@intel.com>
In-Reply-To: <20181211010310.8551-1-keith.busch@intel.com>
References: <20181211010310.8551-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Add the entries for primary cpu and memory node attributes.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 34 ++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 3e90e1f3bf0a..8430d5b261f6 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -90,4 +90,36 @@ Date:		December 2009
 Contact:	Lee Schermerhorn <lee.schermerhorn@hp.com>
 Description:
 		The node's huge page size control/query attributes.
-		See Documentation/admin-guide/mm/hugetlbpage.rst
\ No newline at end of file
+		See Documentation/admin-guide/mm/hugetlbpage.rst
+
+What:		/sys/devices/system/node/nodeX/primary_cpu_nodelist
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The node list of CPUs that have primary access to this node's
+		memory. CPUs not in the list accessing this node's memory may
+		encounter a performance penalty.
+
+What:		/sys/devices/system/node/nodeX/primary_cpu_nodemask
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The node map for CPUs that have primary access to this node's
+		memory. CPUs not in the list accessing this node's memory may
+		encounter a performance penalty.
+
+What:		/sys/devices/system/node/nodeX/primary_mem_nodelist
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The list of memory nodes that this node has primary access.
+		Memory accesses from this node to nodes not in this list may
+		encounter a performance penalty.
+
+What:		/sys/devices/system/node/nodeX/primary_mem_nodemask
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The map of memory nodes that this node has primary access.
+		Memory accesses from this node to nodes not in this map may
+		encounter a performance penalty.
-- 
2.14.4
