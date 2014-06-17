Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id DA7256B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 21:20:54 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id rp16so5118616pbb.9
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 18:20:54 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id pk4si1067961pbc.252.2014.06.16.18.20.52
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 18:20:54 -0700 (PDT)
Date: Tue, 17 Jun 2014 10:25:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 -next 0/9] CMA: generalize CMA reserved area
 management code
Message-ID: <20140617012507.GA6825@js1304-P5Q-DELUXE>
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
 <539EB4C7.3080106@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539EB4C7.3080106@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Jun 16, 2014 at 11:11:35AM +0200, Marek Szyprowski wrote:
> Hello,
> 
> On 2014-06-16 07:40, Joonsoo Kim wrote:
> >Currently, there are two users on CMA functionality, one is the DMA
> >subsystem and the other is the KVM on powerpc. They have their own code
> >to manage CMA reserved area even if they looks really similar.
> >>From my guess, it is caused by some needs on bitmap management. Kvm side
> >wants to maintain bitmap not for 1 page, but for more size. Eventually it
> >use bitmap where one bit represents 64 pages.
> >
> >When I implement CMA related patches, I should change those two places
> >to apply my change and it seem to be painful to me. I want to change
> >this situation and reduce future code management overhead through
> >this patch.
> >
> >This change could also help developer who want to use CMA in their
> >new feature development, since they can use CMA easily without
> >copying & pasting this reserved area management code.
> >
> >v3:
> >   - Simplify old patch 1(log format fix) and move it to the end of patchset.
> >   - Patch 2: Pass aligned base and size to dma_contiguous_early_fixup()
> >   - Patch 5: Add some accessor functions to pass aligned base and size to
> >   dma_contiguous_early_fixup() function
> >   - Patch 5: Move MAX_CMA_AREAS definition to cma.h
> >   - Patch 6: Add CMA region zeroing to PPC KVM's CMA alloc function
> >   - Patch 8: put 'base' ahead of 'size' in cma_declare_contiguous()
> >   - Remaining minor fixes are noted in commit description of each one
> >
> >v2:
> >   - Although this patchset looks very different with v1, the end result,
> >   that is, mm/cma.c is same with v1's one. So I carry Ack to patch 6-7.
> >
> >This patchset is based on linux-next 20140610.
> 
> Thanks for taking care of this. I will test it with my setup and if
> everything goes well, I will take it to my -next tree. If any branch
> is required for anyone to continue his works on top of those patches,
> let me know, I will also prepare it.

Hello,

I'm glad to hear that. :)
But, there is one concern. As you already know, I am preparing further
patches (Aggressively allocate the pages on CMA reserved memory). It
may be highly related to MM branch and also slightly depends on this CMA
changes. In this case, what is the best strategy to merge this
patchset? IMHO, Anrew's tree is more appropriate branch. If there is
no issue in this case, I am willing to develope further patches based
on your tree.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
