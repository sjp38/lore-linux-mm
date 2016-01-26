From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 08/17] xen,
	mm: Set IORESOURCE_SYSTEM_RAM to System RAM
Date: Tue, 26 Jan 2016 21:57:24 +0100
Message-ID: <1453841853-11383-9-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-arch@vger.kernel.org, Andrew Banman <abanman@sgi.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dan Williams <dan.j.williams@intel.com>, LKML <linux-kernel@vger.kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm <linux-mm@kvack.org>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

Set IORESOURCE_SYSTEM_RAM in struct resource.flags of "System RAM"
entries.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Acked-by: David Vrabel <david.vrabel@citrix.com> # xen
Cc: Andrew Banman <abanman@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Rientjes <rientjes@google.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: xen-devel@lists.xenproject.org
Link: http://lkml.kernel.org/r/1452020081-26534-8-git-send-email-toshi.kani@hpe.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 drivers/xen/balloon.c | 2 +-
 mm/memory_hotplug.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 12eab503efd1..dc4305b407bf 100644
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
index 4af58a3a8ffa..979b18cbd343 100644
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
2.3.5
