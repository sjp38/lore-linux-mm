Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 41C486B0009
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 10:59:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e14so7891306pfi.9
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 07:59:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a5si8557082pff.182.2018.04.15.07.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 15 Apr 2018 07:59:55 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: centralize SWIOTLB config symbol and misc other cleanups
Date: Sun, 15 Apr 2018 16:59:35 +0200
Message-Id: <20180415145947.1248-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

Hi all,

this seris aims for a single defintion of the Kconfig symbol.  To get
there various cleanups, mostly about config symbols are included as well.
