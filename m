Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A569F6B027D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:24:20 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a24-v6so12593512pfn.12
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:24:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o7si9899230pgh.403.2018.11.14.00.24.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:24:19 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 17/34] powerpc/powernv: remove pnv_npu_dma_set_mask
Date: Wed, 14 Nov 2018 09:22:57 +0100
Message-Id: <20181114082314.8965-18-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

These devices are not PCIe devices and do not have associated dma map
ops, so this is just dead code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/platforms/powernv/pci-ioda.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index afbb73cd3c5b..1d9f446f3eff 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -3688,14 +3688,6 @@ static const struct pci_controller_ops pnv_pci_ioda_controller_ops = {
 	.shutdown		= pnv_pci_ioda_shutdown,
 };
 
-static int pnv_npu_dma_set_mask(struct pci_dev *npdev, u64 dma_mask)
-{
-	dev_err_once(&npdev->dev,
-			"%s operation unsupported for NVLink devices\n",
-			__func__);
-	return -EPERM;
-}
-
 static const struct pci_controller_ops pnv_npu_ioda_controller_ops = {
 	.dma_dev_setup		= pnv_pci_dma_dev_setup,
 #ifdef CONFIG_PCI_MSI
@@ -3705,7 +3697,6 @@ static const struct pci_controller_ops pnv_npu_ioda_controller_ops = {
 	.enable_device_hook	= pnv_pci_enable_device_hook,
 	.window_alignment	= pnv_pci_window_alignment,
 	.reset_secondary_bus	= pnv_pci_reset_secondary_bus,
-	.dma_set_mask		= pnv_npu_dma_set_mask,
 	.shutdown		= pnv_pci_ioda_shutdown,
 };
 
-- 
2.19.1
