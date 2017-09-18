Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27E386B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 01:22:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 11so15944137pge.4
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 22:22:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 43si4338593plb.617.2017.09.17.22.22.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 22:22:11 -0700 (PDT)
Date: Sun, 17 Sep 2017 22:22:08 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V5 2/3] mm: dmapool: Align to ARCH_DMA_MINALIGN in
 non-coherent DMA mode
Message-ID: <20170918052208.GB29118@infradead.org>
References: <1505708548-4750-1-git-send-email-chenhc@lemote.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505708548-4750-1-git-send-email-chenhc@lemote.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huacai Chen <chenhc@lemote.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fuxin Zhang <zhangfx@lemote.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

The dmapool code uses dma_alloc_coherent to allocate each element,
and dma_alloc_coherent must align to ARCH_DMA_MINALIGN already.
If you implementation doesn't do that it needs to be fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
