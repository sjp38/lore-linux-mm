Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE046B027A
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 11:48:03 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id f78so122740618oih.7
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 08:48:03 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id g66si9556424otb.41.2016.10.28.08.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 08:48:02 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id 62so676105oif.1
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 08:48:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161025153220.4815.61239.stgit@ahduyck-blue-test.jf.intel.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 28 Oct 2016 08:48:01 -0700
Message-ID: <CAKgT0UfOZuRnon84_8Bdn5muoi7=Xrwd7Kbxi4C8jiXpyX7-gg@mail.gmail.com>
Subject: Re: [net-next PATCH 00/27] Add support for DMA writable pages being
 writable by the network stack
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: Netdev <netdev@vger.kernel.org>, intel-wired-lan <intel-wired-lan@lists.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.h.duyck@intel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>

On Tue, Oct 25, 2016 at 8:36 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> The first 22 patches in the set add support for the DMA attribute
> DMA_ATTR_SKIP_CPU_SYNC on multiple platforms/architectures.  This is needed
> so that we can flag the calls to dma_map/unmap_page so that we do not
> invalidate cache lines that do not currently belong to the device.  Instead
> we have to take care of this in the driver via a call to
> sync_single_range_for_cpu prior to freeing the Rx page.
>
> Patch 23 adds support for dma_map_page_attrs and dma_unmap_page_attrs so
> that we can unmap and map a page using the DMA_ATTR_SKIP_CPU_SYNC
> attribute.
>
> Patch 24 adds support for freeing a page that has multiple references being
> held by a single caller.  This way we can free page fragments that were
> allocated by a given driver.
>
> The last 3 patches use these updates in the igb driver to allow for us to
> reimpelement the use of build_skb.
>
> My hope is to get the series accepted into the net-next tree as I have a
> number of other Intel drivers I could then begin updating once these
> patches are accepted.
>
> v1: Split out changes DMA_ERROR_CODE fix for swiotlb-xen
>     Minor fixes based on issues found by kernel build bot
>     Few minor changes for issues found on code review
>     Added Acked-by for patches that were acked and not changed

So the feedback for this set has been mostly just a few "Acked-by"s,
and it looks like the series was marked as "Not Applicable" in
patchwork.  I was wondering what the correct merge strategy for this
patch set should be going forward?

I was wondering if I should be looking at breaking up the set and
splitting it over a few different trees, or if I should just hold onto
it and resubmit it when the merge window opens?  My preference would
be to submit it as a single set so I can know all the patches are
present to avoid any possible regressions due to only part of the set
being present.

Anyway, I am just trying to figure out how best to proceed from here
since these patch sets that touch multiple areas are always
complicated to get submitted.

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
