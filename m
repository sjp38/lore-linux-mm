Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7B36B025B
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 18:38:05 -0500 (EST)
Received: by obciw8 with SMTP id iw8so144926674obc.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:38:05 -0800 (PST)
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com. [15.201.208.56])
        by mx.google.com with ESMTPS id rl4si9465174obc.91.2015.12.14.15.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 15:38:05 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 07/11] memory-hotplug: Set IORESOURCE_SYSTEM_RAM to System RAM
Date: Mon, 14 Dec 2015 16:37:22 -0700
Message-Id: <1450136246-17053-7-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hpe.com>

Set IORESOURCE_SYSTEM_RAM to the flags of memory hotplug resource
ranges with "System RAM".

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 mm/memory_hotplug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 67d488a..9458423 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -136,7 +136,7 @@ static struct resource *register_memory_resource(u64 start, u64 size)
 	res->name = "System RAM";
 	res->start = start;
 	res->end = start + size - 1;
-	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	if (request_resource(&iomem_resource, res) < 0) {
 		pr_debug("System RAM resource %pR cannot be added\n", res);
 		kfree(res);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
