Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD926B000A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:25:30 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id e3-v6so979521pld.13
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:25:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 44-v6si14414634pla.322.2018.10.09.06.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:25:26 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: use generic DMA mapping code in powerpc V3
Date: Tue,  9 Oct 2018 15:24:27 +0200
Message-Id: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Hi all,

this series switches the powerpc port to use the generic swiotlb and
noncoherent dma ops, and to use more generic code for the coherent
direct mapping, as well as removing a lot of dead code.

The changes since v1 are to big to list and v2 was not posted in public.

As this series is very large and depends on the dma-mapping tree I've
also published a git tree:

    git://git.infradead.org/users/hch/misc.git powerpc-dma.3

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.3
