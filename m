Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id EB3DD6B0069
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:24:04 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 74DE1E0059
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:30:01 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345wCg78388918
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:12 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wGAB026729
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:17 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 11/25] powerpc: Print page size info during boot
Date: Thu,  4 Apr 2013 11:27:49 +0530
Message-Id: <1365055083-31956-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This gives hint about different base and actual page size combination
supported by the platform.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/hash_utils_64.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 56ff4bb..1f2ebbd 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -315,7 +315,7 @@ static int __init htab_dt_scan_page_sizes(unsigned long node,
 	prop = (u32 *)of_get_flat_dt_prop(node,
 					  "ibm,segment-page-sizes", &size);
 	if (prop != NULL) {
-		DBG("Page sizes from device-tree:\n");
+		pr_info("Page sizes from device-tree:\n");
 		size /= 4;
 		cur_cpu_spec->mmu_features &= ~(MMU_FTR_16M_PAGE);
 		while(size > 0) {
@@ -369,10 +369,10 @@ static int __init htab_dt_scan_page_sizes(unsigned long node,
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
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
