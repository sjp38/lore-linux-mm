Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 9B8E36B00A7
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 05:29:26 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v1 12/12] doc, page_alloc, acpi, mem-hotplug: Add doc for movablecore=acpi boot option.
Date: Fri, 19 Apr 2013 17:31:49 +0800
Message-Id: <1366363909-12771-13-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1366363909-12771-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1366363909-12771-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, paulmck@linux.vnet.ibm.com, dhowells@redhat.com, davej@redhat.com, agordeev@redhat.com, suresh.b.siddha@intel.com, mst@redhat.com, yinghai@kernel.org, penberg@kernel.org, jacob.shin@amd.com, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, rientjes@google.com, tj@kernel.org, laijs@cn.fujitsu.com, hannes@cmpxchg.org, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since we modify movablecore boot option to support
"movablecore=acpi", this patch adds doc for it.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 4609e81..a1c515b 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1649,6 +1649,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
+	movablecore=acpi	[KNL,X86] This parameter will enable the
+			kernel to arrange ZONE_MOVABLE with the help of
+			Hot-Pluggable Field in SRAT. All the hotpluggable
+			memory will be arranged in ZONE_MOVABLE.
+			NOTE: Any node which the kernel resides in will
+			      always be un-hotpluggable so that the kernel
+			      will always have enough memory to boot.
+
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
