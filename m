Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2AC6B000D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:23:43 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e97-v6so11542585plb.10
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:23:43 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b137-v6si24418549pfb.144.2018.11.14.00.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:23:42 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/34] powerpc: allow NOT_COHERENT_CACHE for amigaone
Date: Wed, 14 Nov 2018 09:22:42 +0100
Message-Id: <20181114082314.8965-3-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

AMIGAONE select NOT_COHERENT_CACHE, so we better allow it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/platforms/Kconfig.cputype | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index f4e2c5729374..6fedbf349fce 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -412,7 +412,8 @@ config NR_CPUS
 
 config NOT_COHERENT_CACHE
 	bool
-	depends on 4xx || PPC_8xx || E200 || PPC_MPC512x || GAMECUBE_COMMON
+	depends on 4xx || PPC_8xx || E200 || PPC_MPC512x || \
+		GAMECUBE_COMMON || AMIGAONE
 	default n if PPC_47x
 	default y
 
-- 
2.19.1
