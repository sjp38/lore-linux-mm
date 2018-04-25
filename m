Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2966B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 01:15:48 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t13so10049754pgu.23
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 22:15:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p6si14833701pfk.357.2018.04.24.22.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Apr 2018 22:15:47 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: centralize SWIOTLB config symbol and misc other cleanups V3
Date: Wed, 25 Apr 2018 07:15:26 +0200
Message-Id: <20180425051539.1989-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: sstabellini@kernel.org, x86@kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

Hi all,

this seris aims for a single defintion of the Kconfig symbol.  To get
there various cleanups, mostly about config symbols are included as well.

Changes since V2:
 - swiotlb doesn't need the dma_length field by itself, so don't select it
 - don't offer a user visible SWIOTLB choice

Chages since V1:
 - fixed a incorrect Reviewed-by that should be a Signed-off-by.
