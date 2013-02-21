Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 14AB86B0030
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:48:09 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 22:16:13 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 5AC6CE0050
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:19:03 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LGlwTG28573824
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:58 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LGlwmp011436
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 03:48:00 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH -V2 19/21] powerpc/THP: hypervisor require few WIMG bit set
Date: Thu, 21 Feb 2013 22:17:26 +0530
Message-Id: <1361465248-10867-20-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Without this insert will return H_PARAMETER error. Also use
the signed variant when printing error.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/largepage-hash64.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/powerpc/mm/largepage-hash64.c b/arch/powerpc/mm/largepage-hash64.c
index 2a5fc39..20a626e 100644
--- a/arch/powerpc/mm/largepage-hash64.c
+++ b/arch/powerpc/mm/largepage-hash64.c
@@ -123,6 +123,8 @@ repeat:
 		/* Add in WIMG bits. FIXME!! enabled by default */
 		rflags |= (new_pmd & (_PAGE_WRITETHRU | _PAGE_NO_CACHE |
 				      _PAGE_COHERENT | _PAGE_GUARDED));
+#else
+		rflags |= _PAGE_COHERENT;
 #endif
 		/* Insert into the hash table, primary slot */
 		slot = ppc_md.hpte_insert(hpte_group, vpn, pa, rflags, 0,
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
