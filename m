Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id A6B406B0255
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 14:30:24 -0400 (EDT)
Received: by qkdw123 with SMTP id w123so32033794qkd.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 11:30:24 -0700 (PDT)
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com. [129.33.205.207])
        by mx.google.com with ESMTPS id a65si4874392qkh.24.2015.09.08.11.30.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Sep 2015 11:30:24 -0700 (PDT)
Received: from /spool/local
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 8 Sep 2015 14:30:23 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 69E846E8047
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 14:22:05 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t88IULiM51707966
	for <linux-mm@kvack.org>; Tue, 8 Sep 2015 18:30:21 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t88IUKJX011182
	for <linux-mm@kvack.org>; Tue, 8 Sep 2015 14:30:21 -0400
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH  2/2] powerpc:numa Do not allocate bootmem memory for non existing nodes
Date: Wed,  9 Sep 2015 00:01:47 +0530
Message-Id: <1441737107-23103-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
In-Reply-To: <1441737107-23103-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <1441737107-23103-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org
Cc: nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, zhong@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, raghavendra.kt@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 arch/powerpc/mm/numa.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 8b9502a..8d8a541 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -80,7 +80,7 @@ static void __init setup_node_to_cpumask_map(void)
 		setup_nr_node_ids();
 
 	/* allocate the map */
-	for (node = 0; node < nr_node_ids; node++)
+	for_each_node(node)
 		alloc_bootmem_cpumask_var(&node_to_cpumask_map[node]);
 
 	/* cpumask_of_node() will now work */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
