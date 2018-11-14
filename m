Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEC4E6B026A
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:23:47 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id c15-v6so11529465pls.15
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:23:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f34-v6si25044327ple.218.2018.11.14.00.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:23:46 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/34] powerpc/dma: remove the unused ISA_DMA_THRESHOLD export
Date: Wed, 14 Nov 2018 09:22:44 +0100
Message-Id: <20181114082314.8965-5-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/powerpc/kernel/setup_32.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 81909600013a..07f7e6aaf104 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -59,7 +59,6 @@ unsigned long ISA_DMA_THRESHOLD;
 unsigned int DMA_MODE_READ;
 unsigned int DMA_MODE_WRITE;
 
-EXPORT_SYMBOL(ISA_DMA_THRESHOLD);
 EXPORT_SYMBOL(DMA_MODE_READ);
 EXPORT_SYMBOL(DMA_MODE_WRITE);
 
-- 
2.19.1
