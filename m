Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8AC88E006F
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 20:05:54 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id u17so8625860pgn.17
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 17:05:54 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si11402278pfj.276.2018.12.10.17.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 17:05:53 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 10/12] Documentation/ABI: Add node cache attributes
Date: Mon, 10 Dec 2018 18:03:08 -0700
Message-Id: <20181211010310.8551-11-keith.busch@intel.com>
In-Reply-To: <20181211010310.8551-1-keith.busch@intel.com>
References: <20181211010310.8551-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Add the attributes for the system memory side caches.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 34 +++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 6cdb0643f9fd..63a757b8a29e 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -151,3 +151,37 @@ Contact:	Keith Busch <keith.busch@intel.com>
 Description:
 		Write latency in nanosecondss available to memory initiators
 		found in primary_cpu_nodemask.
+
+What:		/sys/devices/system/node/nodeX/side_cache/indexY/associativity
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The caches associativity: 0 for direct mapped, non-zero if
+		indexed.
+
+What:		/sys/devices/system/node/nodeX/side_cache/indexY/level
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This cache's level in the memory hierarchy. Matches 'Y' in the
+		directory name.
+
+What:		/sys/devices/system/node/nodeX/side_cache/indexY/line_size
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The number of bytes accessed from the next cache level on a
+		cache miss.
+
+What:		/sys/devices/system/node/nodeX/side_cache/indexY/size
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The size of this memory side cache in bytes.
+
+What:		/sys/devices/system/node/nodeX/side_cache/indexY/write_policy
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The cache write policy: 0 for write-back, 1 for write-through,
+		2 for other or unknown.
-- 
2.14.4
