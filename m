Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 868D26B02BA
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 07:15:41 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j3so3168718wrb.18
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 04:15:41 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id p20si19406869wrb.136.2018.02.22.04.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 04:15:40 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 2/5] powerpc: mm: Use memblock API for PPC32 page_is_ram
Date: Thu, 22 Feb 2018 13:15:13 +0100
Message-Id: <20180222121516.23415-3-j.neuschaefer@gmx.net>
In-Reply-To: <20180222121516.23415-1-j.neuschaefer@gmx.net>
References: <20180222121516.23415-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, Christophe LEROY <christophe.leroy@c-s.fr>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Oliver O'Halloran <oohall@gmail.com>, Joe Perches <joe@perches.com>

To support accurate checking for different blocks of memory on PPC32,
use the same memblock-based approach that's already used on PPC64 also
on PPC32.

Signed-off-by: Jonathan NeuschA?fer <j.neuschaefer@gmx.net>
---
 arch/powerpc/mm/mem.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index da4e1555d61d..a42b86e2a34c 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -82,11 +82,7 @@ static inline pte_t *virt_to_kpte(unsigned long vaddr)
 
 int page_is_ram(unsigned long pfn)
 {
-#ifndef CONFIG_PPC64	/* XXX for now */
-	return pfn < max_pfn;
-#else
 	return memblock_is_memory(__pfn_to_phys(pfn));
-#endif
 }
 
 pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
