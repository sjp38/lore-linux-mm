Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D9E376B0006
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 11:46:51 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r4-v6so13349057wrt.2
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 08:46:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t184-v6sor2249044wmb.7.2018.08.13.08.46.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 08:46:50 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v2 1/3] mm/memory-hotplug: Drop unused args from remove_memory_section
Date: Mon, 13 Aug 2018 17:46:37 +0200
Message-Id: <20180813154639.19454-2-osalvador@techadventures.net>
In-Reply-To: <20180813154639.19454-1-osalvador@techadventures.net>
References: <20180813154639.19454-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, rafael@kernel.org, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

unregister_memory_section() calls remove_memory_section()
with three arguments:

* node_id
* section
* phys_device

Neither node_id nor phys_device are used.
Let us drop them from the function.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
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
