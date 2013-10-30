Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AB6076B0035
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 01:53:50 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id w10so482705pde.30
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 22:53:50 -0700 (PDT)
Received: from psmtp.com ([74.125.245.166])
        by mx.google.com with SMTP id jp3si16773875pbc.186.2013.10.29.22.53.48
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 22:53:49 -0700 (PDT)
Date: Wed, 30 Oct 2013 14:53:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: OMAPFB: CMA allocation failures
Message-ID: <20131030055354.GG17013@bbox>
References: <737255712.30460.1383050855911.JavaMail.apache@mail83.abv.bg>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <737255712.30460.1383050855911.JavaMail.apache@mail83.abv.bg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?0JjQstCw0LnQu9C+INCU0LjQvNC40YLRgNC+0LI=?= <freemangordon@abv.bg>
Cc: pavel@ucw.cz, sre@debian.org, tomi.valkeinen@ti.com, pali.rohar@gmail.com, pc+n900@asdf.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, D?D2D?D1D>>D 3/4 


On Tue, Oct 29, 2013 at 02:47:35PM +0200, D?D2D?D1D>>D 3/4  D?D,D 1/4 D,N?N?D 3/4 D2 wrote:
>  
> Hi,
> 
> 
>  >-------- D?N?D,D3D,D 1/2 D?D>>D 1/2 D 3/4  D?D,N?D 1/4 D 3/4  --------
>  >D?N?:  Minchan Kim 
>  >D?N?D 1/2 D 3/4 N?D 1/2 D 3/4 : Re: OMAPFB: CMA allocation failures
>  >D?D 3/4 : D?D2D?D1D>>D 3/4  D?D,D 1/4 D,N?N?D 3/4 D2 
>  >D?D.D?N?D?N?DuD 1/2 D 3/4  D 1/2 D?: D?D 3/4 D 1/2 DuD'DuD>>D 1/2 D,Do, 2013, D?DoN?D 3/4 D 1/4 D2N?D, 28 09:37:48 EET
>  >
>  >
>  >Hello,
>  >
>  >On Tue, Oct 15, 2013 at 09:49:51AM +0300, D?D2D?D1D>>D 3/4  D?D,D 1/4 D,N?N?D 3/4 D2 wrote:
>  >>  Hi
>  >> 
>  >>  >-------- D?N?D,D3D,D 1/2 D?D>>D 1/2 D 3/4  D?D,N?D 1/4 D 3/4  --------
>  >>  >D?N?:  Tomi Valkeinen 
>  >>  >D?N?D 1/2 D 3/4 N?D 1/2 D 3/4 : Re: OMAPFB: CMA allocation failures
>  >>  >D?D 3/4 : D?D2D?D1D>>D 3/4  D?D,D 1/4 D,N?N?D 3/4 D2
>  >> 	
>  >>  >D?D.D?N?D?N?DuD 1/2 D 3/4  D 1/2 D?: D?D 3/4 D 1/2 DuD'DuD>>D 1/2 D,Do, 2013, D?DoN?D 3/4 D 1/4 D2N?D, 14 09:04:35 EEST
>  >>  >
>  >>  >
>  >>  >Hi,
>  >>  >
>  >>  >On 12/10/13 17:43, D?D2D?D1D>>D 3/4  D?D,D 1/4 D,N?N?D 3/4 D2 wrote:
>  >>  >>  Hi Tomi,
>  >>  >> 
>  >>  >> patch http://lists.infradead.org/pipermail/linux-arm-kernel/2012-November/131269.html modifies
>  >>  >> omapfb driver to use DMA API to allocate framebuffer memory instead of preallocating VRAM.
>  >>  >> 
>  >>  >> With this patch I see a lot of:
>  >>  >> 
>  >>  >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.879577] cma: dma_alloc_from_contiguous(cma c05f5844, count 192, align 8)
>  >>  >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.914215] cma: dma_alloc_from_contiguous(): memory range at c07df000 is busy, retrying
>  >>  >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.933502] cma: dma_alloc_from_contiguous(): memory range at c07e1000 is busy, retrying
>  >>  >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.940032] cma: dma_alloc_from_contiguous(): memory range at c07e3000 is busy, retrying
>  >>  >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.966644] cma: dma_alloc_from_contiguous(): memory range at c07e5000 is busy, retrying
>  >>  >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.976867] cma: dma_alloc_from_contiguous(): memory range at c07e7000 is busy, retrying
>  >>  >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2055.038055] cma: dma_alloc_from_contiguous(): memory range at c07e9000 is busy, retrying
>  >>  >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2055.038116] cma: dma_alloc_from_contiguous(): returned   (null)
>  >>  >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2055.038146] omapfb omapfb: failed to allocate framebuffer
>  >>  >> 
>  >>  >> errors while trying to play a video on N900 with Maemo 5 (Fremantle) on top of linux-3.12rc1.
>  >>  >> It is deffinitely the CMA that fails to allocate the memory most of the times, but I wonder
>  >>  >> how reliable CMA is to be used in omapfb. I even reserved 64MB for CMA, but that made no
>  >>  >> difference. If CMA is disabled, the memory allocation still fails as obviously it is highly
>  >>  >> unlikely there will be such a big chunk of continuous free memory on RAM limited device like
>  >>  >> N900. 
>  >>  >> 
>  >>  >> One obvious solution is to just revert the removal of VRAM memory allocator, but that would
>  >>  >> mean I'll have to maintain a separate tree with all the implications that brings.
>  >>  >> 
>  >>  >> What would you advise on how to deal with the issue?
>  >>  >
>  >>  >I've not seen such errors, and I'm no expert on CMA. But I guess the
>  >>  >contiguous memory area can get fragmented enough no matter how hard one
>  >>  >tries to avoid it. The old VRAM system had the same issue, although it
>  >>  >was quite difficult to hit it.
>  >> 
>  >> I am using my n900 as a daily/only device since the beginning of 2010, never seen such an 
>  >> issue with video playback. And as a maintainer of one of the community supported kernels for
>  >> n900 (kernel-power) I've never had such an issue reported. On stock kernel and derivatives of
>  >> course. It seems VRAM allocator is virtually impossible to fail, while with CMA OMAPFB fails on
>  >> the first video after boot-up.
>  >> 
>  >> When saying you've not seen such an issue - did you actually test video playback, on what
>  >> device and using which distro? Did you use DSP accelerated decoding?
>  >> 
>  >>  >64MB does sound quite a lot, though. I wonder what other drivers are
>  >>  >using CMA, and how do they manage to allocate so much memory and
>  >>  >fragment it so badly... With double buffering, N900 should only need
>  >>  >something like 3MB for the frame buffer.
>  >> 
>  >> Sure, 64 MB is a lot, but I just wanted to see if that would make any difference. And for 720p 
>  >> 3MB is not enough, something like 8MB is needed.
>  >> 
>  >>  >With a quick glance I didn't find any debugfs or such files to show
>  >>  >information about the CMA area. It'd be helpful to find out what's going
>  >>  >on there. Or maybe normal allocations are fragmenting the CMA area, but
>  >>  >for some reason they cannot be moved? Just guessing.
>  >> 
>  >> I was able to track down the failures to:
>  >> http://lxr.free-electrons.com/source/mm/migrate.c#L320
>  >
>  >That path is for anonymous page migration so the culprit I can think of
>  >is that you did get_user_pages on those anonymous pages for pin them.
>  >Right?
>  >
> 
> I grepped through the code and there are lots of places where get_user_pages is called, though
> I suspect either SGX or DSP (or both) drivers to be the ones to blame. Both of them are active
> and needed for HW accelerated video decoding.
> 
>  >If so, it's no surpse that fails the migration and CMA doesn't work.
>  >
>  >-- 
>  >Kind regards,
>  >Minchan Kim
>  >
> 
> Well, if CMA is to be reliable, I would expect some logic to take care about get_user_pages

First of all, CMA is never reliable.

> causing MIGRATE_CMA pages to be effectively made non-migratable, either by migrating them out of
> CMA area before they got pinned or by providing a mechanism to migrate them when needed. I am far 
> from knowing the nuts and bolts of MM and CMA, but so far I failed to see any such logic. Without 

If you read below links you attached, you could know why it doesn't accept.

> it, CMA could be fine for allocating small buffers, but when we talk about framebuffer memory 
> needed for 720p playback(for example) on a RAM limited embedded device, it is too fragile, IMO.

True.

> 
> BTW quick googling shows I am not the first one to encounter similar problems [0], [1], I don't
> see solution for. 
> 
> However, back to omapfb - my understanding is that the way it uses CMA (in its current form) is
> prone to allocation failures way beyond acceptable. 

Basically, fragile subsystem shouldn't use CMA, otherwise, your platform should support process
killing to unpin some pages, Yeah I know it's not 100% solution and very horrible but I know
some insane people have done it.

I just post an idea.
http://marc.info/?l=linux-mm&m=138311160522311&w=2
If anybody has a interest, maybe we will move that way.

Thanks.

> 
> Tomi, what do you think about adding module parameters to allow pre-allocating framebuffer memory
> from CMA during boot? Or re-implement VRAM allocator to use CMA? As a good side-effect 
> OMAPFB_GET_VRAM_INFO will no longer return fake values.
> 
> Regards,
> Ivo
> 
> [0] http://lwn.net/Articles/541423/
> [1] https://lkml.org/lkml/2012/11/29/69
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
