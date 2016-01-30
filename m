Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id E6AC96B0009
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:32:03 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id o185so50776677pfb.1
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:32:03 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id oq8si8270785pac.174.2016.01.30.01.32.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:32:03 -0800 (PST)
Date: Sat, 30 Jan 2016 01:30:36 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-782b86641e5d471e9eb1cf0072c012d2f758e568@git.kernel.org>
Reply-To: konrad.wilk@oracle.com, toshi.kani@hpe.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, mgorman@techsingularity.net,
        hpa@zytor.com, bp@suse.de, torvalds@linux-foundation.org, bp@alien8.de,
        luto@amacapital.net, brgerst@gmail.com, peterz@infradead.org,
        dan.j.williams@intel.com, dvlasenk@redhat.com,
        boris.ostrovsky@oracle.com, mingo@kernel.org,
        akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com,
        rientjes@google.com, tglx@linutronix.de, mcgrof@suse.com,
        abanman@sgi.com, toshi.kani@hp.com, guz.fnst@cn.fujitsu.com,
        tangchen@cn.fujitsu.com
In-Reply-To: <1453841853-11383-9-git-send-email-bp@alien8.de>
References: <1453841853-11383-9-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] xen, mm:
  Set IORESOURCE_SYSTEM_RAM to System RAM
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: abanman@sgi.com, mcgrof@suse.com, tglx@linutronix.de, tangchen@cn.fujitsu.com, guz.fnst@cn.fujitsu.com, toshi.kani@hp.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, boris.ostrovsky@oracle.com, mingo@kernel.org, rientjes@google.com, peterz@infradead.org, brgerst@gmail.com, luto@amacapital.net, bp@alien8.de, dvlasenk@redhat.com, dan.j.williams@intel.com, mgorman@techsingularity.net, linux-kernel@vger.kernel.org, konrad.wilk@oracle.com, linux-mm@kvack.org, toshi.kani@hpe.com, torvalds@linux-foundation.org, hpa@zytor.com, bp@suse.de

Commit-ID:  782b86641e5d471e9eb1cf0072c012d2f758e568
Gitweb:     http://git.kernel.org/tip/782b86641e5d471e9eb1cf0072c012d2f758e568
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:24 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:58 +0100

xen, mm: Set IORESOURCE_SYSTEM_RAM to System RAM

Set IORESOURCE_SYSTEM_RAM in struct resource.flags of "System
RAM" entries.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Acked-by: David Vrabel <david.vrabel@citrix.com> # xen
Cc: Andrew Banman <abanman@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: xen-devel@lists.xenproject.org
Link: http://lkml.kernel.org/r/1453841853-11383-9-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 drivers/xen/balloon.c | 2 +-
 mm/memory_hotplug.c   | 2 +-
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
index 4af58a3..979b18c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -138,7 +138,7 @@ static struct resource *register_memory_resource(u64 start, u64 size)
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
