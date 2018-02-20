Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76F2E6B000E
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:16:35 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w102so8358405wrb.21
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:16:35 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id l4si13768628wre.478.2018.02.20.08.16.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 08:16:34 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 4/6] powerpc: numa: Restrict fake NUMA enulation to CONFIG_NUMA systems
Date: Tue, 20 Feb 2018 17:14:22 +0100
Message-Id: <20180220161424.5421-5-j.neuschaefer@gmx.net>
In-Reply-To: <20180220161424.5421-1-j.neuschaefer@gmx.net>
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Michael Bringmann <mwb@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>

Signed-off-by: Jonathan NeuschA?fer <j.neuschaefer@gmx.net>
---
 arch/powerpc/mm/numa.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index df03a65b658f..dfe279529463 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -738,7 +738,8 @@ static void __init setup_nonnuma(void)
 		start_pfn = memblock_region_memory_base_pfn(reg);
 		end_pfn = memblock_region_memory_end_pfn(reg);
 
-		fake_numa_create_new_node(end_pfn, &nid);
+		if (IS_ENABLED(CONFIG_NUMA))
+			fake_numa_create_new_node(end_pfn, &nid);
 		memblock_set_node(PFN_PHYS(start_pfn),
 				  PFN_PHYS(end_pfn - start_pfn),
 				  &memblock.memory, nid);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
