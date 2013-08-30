Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id DC1FB6B0033
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 21:30:09 -0400 (EDT)
Message-ID: <521FF57A.8080702@huawei.com>
Date: Fri, 30 Aug 2013 09:29:30 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 3/4] x86/srat: use NUMA_NO_NODE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, mingo@redhat.com

setup_node() return NUMA_NO_NODE or valid node id(>=0), So use more appropriate
"if (node == NUMA_NO_NODE)" instead of "if (node < 0)"

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 arch/x86/mm/srat.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index cdd0da9..97fea4e 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -76,7 +76,7 @@ acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa)
 		return;
 	}
 	node = setup_node(pxm);
-	if (node < 0) {
+	if (node == NUMA_NO_NODE) {
 		printk(KERN_ERR "SRAT: Too many proximity domains %x\n", pxm);
 		bad_srat();
 		return;
@@ -112,7 +112,7 @@ acpi_numa_processor_affinity_init(struct acpi_srat_cpu_affinity *pa)
 	if (acpi_srat_revision >= 2)
 		pxm |= *((unsigned int*)pa->proximity_domain_hi) << 8;
 	node = setup_node(pxm);
-	if (node < 0) {
+	if (node == NUMA_NO_NODE) {
 		printk(KERN_ERR "SRAT: Too many proximity domains %x\n", pxm);
 		bad_srat();
 		return;
@@ -164,7 +164,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 		pxm &= 0xff;
 
 	node = setup_node(pxm);
-	if (node < 0) {
+	if (node == NUMA_NO_NODE) {
 		printk(KERN_ERR "SRAT: Too many proximity domains.\n");
 		goto out_err_bad_srat;
 	}
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
