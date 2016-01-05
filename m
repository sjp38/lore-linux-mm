Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id C169B800CA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:55:36 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id wp13so146458472obc.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:55:36 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id r8si5806836oey.99.2016.01.05.10.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:55:36 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 08/17] xen, mm: Set IORESOURCE_SYSTEM_RAM to System RAM
Date: Tue,  5 Jan 2016 11:54:32 -0700
Message-Id: <1452020081-26534-8-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Toshi Kani <toshi.kani@hpe.com>

Set IORESOURCE_SYSTEM_RAM to 'flags' of struct resource entries
with "System RAM".

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org
Acked-by: David Vrabel <david.vrabel@citrix.com> # xen
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 drivers/xen/balloon.c |    2 +-
 mm/memory_hotplug.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 12eab50..dc4305b 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -257,7 +257,7 @@ static struct resource *additional_memory_resource(phys_addr_t size)
 		return NULL;
 
 	res->name = "System RAM";
-	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 
 	ret = allocate_resource(&iomem_resource, res,
 				size, 0, -1,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a042a9d..0712585 100644
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
