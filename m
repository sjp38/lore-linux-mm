Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2546D8E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 12:03:37 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id o63-v6so2683550wma.2
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 09:03:37 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e18si5055197wra.391.2018.12.08.09.03.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Dec 2018 09:03:35 -0800 (PST)
Date: Sat, 8 Dec 2018 18:03:34 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20181208170334.GB15020@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Just as a warning:  this series now has some conflicts with the dma
mapping tree due to the ->mapping_error removal, and there might be
some bigger ones if the direct calls for the direct mapping code series
goes ahead.  None of them affect the early part of the series that do
not touch the actual dma_map_ops instances, though.
