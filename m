Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9CC6B005C
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 01:36:45 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so3820616pbc.12
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:36:45 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ww7si9728196pbc.36.2014.06.15.22.36.41
        for <linux-mm@kvack.org>;
        Sun, 15 Jun 2014 22:36:42 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 -next 9/9] mm, CMA: clean-up log message
Date: Mon, 16 Jun 2014 14:40:51 +0900
Message-Id: <1402897251-23639-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We don't need explicit 'CMA:' prefix, since we already define prefix
'cma:' in pr_fmt. So remove it.

Acked-by: Michal Nazarewicz <mina86@mina86.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/cma.c b/mm/cma.c
index 9961120..4b251b0 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -225,12 +225,12 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	*res_cma = cma;
 	cma_area_count++;
 
-	pr_info("CMA: reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
+	pr_info("Reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
 		(unsigned long)base);
 	return 0;
 
 err:
-	pr_err("CMA: failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
+	pr_err("Failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
 	return ret;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
