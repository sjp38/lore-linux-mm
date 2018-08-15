Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1656B0008
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 10:42:31 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t10-v6so1009583wrs.17
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 07:42:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m193-v6sor440117wma.79.2018.08.15.07.42.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Aug 2018 07:42:30 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v3 1/4] mm/memory-hotplug: Drop unused args from remove_memory_section
Date: Wed, 15 Aug 2018 16:42:16 +0200
Message-Id: <20180815144219.6014-2-osalvador@techadventures.net>
In-Reply-To: <20180815144219.6014-1-osalvador@techadventures.net>
References: <20180815144219.6014-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

unregister_memory_section() calls remove_memory_section()
with three arguments:

* node_id
* section
* phys_device

Neither node_id nor phys_device are used.
Let us drop them from the function.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
---
 drivers/base/memory.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index c8a1cb0b6136..2c622a9a7490 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -752,8 +752,7 @@ unregister_memory(struct memory_block *memory)
 	device_unregister(&memory->dev);
 }
 
-static int remove_memory_section(unsigned long node_id,
-			       struct mem_section *section, int phys_device)
+static int remove_memory_section(struct mem_section *section)
 {
 	struct memory_block *mem;
 
@@ -785,7 +784,7 @@ int unregister_memory_section(struct mem_section *section)
 	if (!present_section(section))
 		return -EINVAL;
 
-	return remove_memory_section(0, section, 0);
+	return remove_memory_section(section);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-- 
2.13.6
