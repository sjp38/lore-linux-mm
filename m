Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA0DA6B000E
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:23:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4-v6so6363055wmc.7
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 09:23:35 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id l8-v6si21038364wrv.161.2018.07.13.09.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 09:23:34 -0700 (PDT)
Message-Id: <237810f0c0051e54eef94777ac5381cc99538a99.1531498345.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1531498345.git.christophe.leroy@c-s.fr>
References: <cover.1531498345.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [RFC PATCH v1 2/4] powerpc: add missing header in pgtable-types.h
Date: Fri, 13 Jul 2018 16:23:33 +0000 (UTC)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, npiggin@gmail.com, aneesh.kumar@linux.ibm.com
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

pte_basic_t is defined in page.h

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/pgtable-types.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/powerpc/include/asm/pgtable-types.h b/arch/powerpc/include/asm/pgtable-types.h
index eccb30b38b47..3d8f68aebea3 100644
--- a/arch/powerpc/include/asm/pgtable-types.h
+++ b/arch/powerpc/include/asm/pgtable-types.h
@@ -2,6 +2,8 @@
 #ifndef _ASM_POWERPC_PGTABLE_TYPES_H
 #define _ASM_POWERPC_PGTABLE_TYPES_H
 
+#include <asm/page.h>
+
 /* PTE level */
 typedef struct { pte_basic_t pte; } pte_t;
 #define __pte(x)	((pte_t) { (x) })
-- 
2.13.3
