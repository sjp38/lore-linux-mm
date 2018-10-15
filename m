Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0546B0005
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 22:45:40 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id h62-v6so20933809itb.4
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 19:45:40 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id a4-v6si6407426itj.80.2018.10.14.19.45.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 14 Oct 2018 19:45:39 -0700 (PDT)
Message-ID: <a99ff76069ab6559a5664382a9079b5fddfee945.camel@kernel.crashing.org>
Subject: Re: [PATCH 16/33] powerpc/powernv: remove dead npu-dma code
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 15 Oct 2018 13:45:26 +1100
In-Reply-To: <7709932d-efb8-2c9b-5128-99cc491c302b@ozlabs.ru>
References: <20181009132500.17643-1-hch@lst.de>
	 <20181009132500.17643-17-hch@lst.de>
	 <7709932d-efb8-2c9b-5128-99cc491c302b@ozlabs.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>, Christoph Hellwig <hch@lst.de>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 2018-10-15 at 12:34 +1100, Alexey Kardashevskiy wrote:
> On 10/10/2018 00:24, Christoph Hellwig wrote:
> > This code has been unused since it was merged and is in the way of
> > cleaning up the DMA code, thus remove it.
> > 
> > This effectively reverts commit 5d2aa710 ("powerpc/powernv: Add support
> > for Nvlink NPUs").
> 
> 
> This code is heavily used by the NVIDIA GPU driver.

Some of it is, yes. And while I don't want to be involved in the
discussion about that specific can of worms, there is code in this file
related to the custom "always error" DMA ops that I suppose we could
remove, which is what is getting in the way of Christoph cleanups. It's
just meant as a debug stuff to catch incorrect attempts at doing the
dma mappings on the wrong "side" of the GPU.

Cheers,
Ben.
