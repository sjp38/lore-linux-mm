Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 32A216B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:47:51 -0500 (EST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 22:14:46 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id EA7F1E004C
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:18:44 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LGlfHw30408770
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:41 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LGlguQ009841
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 03:47:44 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH -V2 01/21] powerpc: Use signed formatting when printing error
Date: Thu, 21 Feb 2013 22:17:08 +0530
Message-Id: <1361465248-10867-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

PAPR define these errors as negative values. So print them accordingly
for easy debugging.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/platforms/pseries/lpar.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
index 0da39fe..a77c35b 100644
--- a/arch/powerpc/platforms/pseries/lpar.c
+++ b/arch/powerpc/platforms/pseries/lpar.c
@@ -155,7 +155,7 @@ static long pSeries_lpar_hpte_insert(unsigned long hpte_group,
 	 */
 	if (unlikely(lpar_rc != H_SUCCESS)) {
 		if (!(vflags & HPTE_V_BOLTED))
-			pr_devel(" lpar err %lu\n", lpar_rc);
+			pr_devel(" lpar err %ld\n", lpar_rc);
 		return -2;
 	}
 	if (!(vflags & HPTE_V_BOLTED))
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
