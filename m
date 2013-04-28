Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 94FEF6B0068
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:37:52 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:02:42 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id CE26C1258051
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:09:26 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJbgJx60555366
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:07:42 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJbkS6003316
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:37:46 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 17/18] powerpc: Print page size info during boot
Date: Mon, 29 Apr 2013 01:07:38 +0530
Message-Id: <1367177859-7893-18-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This gives hint about different base and actual page size combination
supported by the platform.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hash_utils_64.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 33cdc3a..d0eb6d4 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -316,7 +316,7 @@ static int __init htab_dt_scan_page_sizes(unsigned long node,
 	prop = (u32 *)of_get_flat_dt_prop(node,
 					  "ibm,segment-page-sizes", &size);
 	if (prop != NULL) {
-		DBG("Page sizes from device-tree:\n");
+		pr_info("Page sizes from device-tree:\n");
 		size /= 4;
 		cur_cpu_spec->mmu_features &= ~(MMU_FTR_16M_PAGE);
 		while(size > 0) {
@@ -370,10 +370,10 @@ static int __init htab_dt_scan_page_sizes(unsigned long node,
 					       "shift=%d\n", base_shift, shift);
 
 				def->penc[idx] = penc;
-				DBG(" %d: shift=%02x, sllp=%04lx, "
-				    "avpnm=%08lx, tlbiel=%d, penc=%d\n",
-				    idx, shift, def->sllp, def->avpnm,
-				    def->tlbiel, def->penc[idx]);
+				pr_info("base_shift=%d: shift=%d, sllp=0x%04lx,"
+					" avpnm=0x%08lx, tlbiel=%d, penc=%d\n",
+					base_shift, shift, def->sllp,
+					def->avpnm, def->tlbiel, def->penc[idx]);
 			}
 		}
 		return 1;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
