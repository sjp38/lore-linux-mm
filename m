Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id EB85F6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 05:30:28 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id j107so8183230qga.36
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 02:30:28 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id 81si20594305qgx.26.2014.08.11.02.30.27
        for <linux-mm@kvack.org>;
        Mon, 11 Aug 2014 02:30:28 -0700 (PDT)
Date: Mon, 11 Aug 2014 10:30:24 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCHv6 0/5] DMA Atomic pool for arm64
Message-ID: <20140811093024.GF15344@arm.com>
References: <1407529848-6806-1-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1407529848-6806-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, Russell King <linux@arm.linux.org.uk>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>

On Fri, Aug 08, 2014 at 09:30:48PM +0100, Laura Abbott wrote:
> Hi,
> 
> This is v6 of the series to add an atomic pool for arm64 and refactor some of
> the arm dma_atomic code as well.
> 
> Russell, assuming you have no issues I'd like to get your Acked-by before
> Catalin picks this up. As always, testing and reviews are appreiciated.
> 
> Thanks,
> Laura
> 
> 
> v6: Tweaked the commit text to clarify that arm is moving from
> ioremap_page_range to map_vm_area and friends
> 
> v5: v4: Addressed comments from Thierry and Catalin. Updated map_vm_area call in
> dma_common_pages_remap since the API changed.
> 
> v4: Simplified the logic in gen_pool_first_fit_order_align which makes the
> data argument actually unused.
> 
> v3: Now a patch series due to refactoring of arm code. arm and arm64 now both
> use genalloc for atomic pool management. genalloc extensions added.
> DMA remapping code factored out as well.
> 
> v2: Various bug fixes pointed out by David and Ritesh (CMA dependency, swapping
> coherent, noncoherent). I'm still not sure how to address the devicetree
> suggestion by Will [1][2]. I added the devicetree mailing list this time around
> to get more input on this.
> 
> [1] http://lists.infradead.org/pipermail/linux-arm-kernel/2014-April/249180.html
> [2] http://lists.infradead.org/pipermail/linux-arm-kernel/2014-April/249528.html

FWIW: I don't think the device-tree comments need to block this series. I
was just curious as to why they weren't being used.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
