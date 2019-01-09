Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C97C8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:47:59 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id c14so4552196pls.21
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:47:59 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c10si25675731pla.173.2019.01.09.09.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 09:47:58 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 05/13] Documentation/ABI: Add new node sysfs attributes
Date: Wed,  9 Jan 2019 10:43:33 -0700
Message-Id: <20190109174341.19818-6-keith.busch@intel.com>
In-Reply-To: <20190109174341.19818-1-keith.busch@intel.com>
References: <20190109174341.19818-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Add entries for memory initiator and target node class attributes.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 3e90e1f3bf0a..a9c47b4b0eee 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -90,4 +90,27 @@ Date:		December 2009
 Contact:	Lee Schermerhorn <lee.schermerhorn@hp.com>
 Description:
 		The node's huge page size control/query attributes.
-		See Documentation/admin-guide/mm/hugetlbpage.rst
\ No newline at end of file
+		See Documentation/admin-guide/mm/hugetlbpage.rst
+
+What:		/sys/devices/system/node/nodeX/classY/
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The node's relationship to other nodes for access class "Y".
+
+What:		/sys/devices/system/node/nodeX/classY/initiator_nodelist
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The node list of memory initiators that have class "Y" access
+		to this node's memory. CPUs and other memory initiators in
+		nodes not in the list accessing this node's memory may have
+		different performance.
+
+What:		/sys/devices/system/node/nodeX/classY/target_nodelist
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The node list of memory targets that this initiator node has
+		class "Y" access. Memory accesses from this node to nodes not
+		in this list may have differet performance.
-- 
2.14.4
