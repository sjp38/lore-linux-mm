Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id F37846B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 09:44:57 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id vy18so25573617iec.5
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 06:44:57 -0800 (PST)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id g4si9846597igh.45.2015.02.03.06.44.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 06:44:57 -0800 (PST)
Received: by mail-ie0-f180.google.com with SMTP id rl12so25565996iec.11
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 06:44:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150203143715.GQ8656@n2100.arm.linux.org.uk>
References: <20150129143908.GA26493@n2100.arm.linux.org.uk>
	<CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
	<20150129154718.GB26493@n2100.arm.linux.org.uk>
	<CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
	<20150129192610.GE26493@n2100.arm.linux.org.uk>
	<CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
	<20150202165405.GX14009@phenom.ffwll.local>
	<CAF6AEGuESM+e3HSRGM6zLqrp8kqRLGUYvA3KKECdm7m-nt0M=Q@mail.gmail.com>
	<20150203074856.GF14009@phenom.ffwll.local>
	<CAF6AEGu0-TgyE4BjiaSWXQCSk31VU7dogq=6xDRUhi79rGgbxg@mail.gmail.com>
	<20150203143715.GQ8656@n2100.arm.linux.org.uk>
Date: Tue, 3 Feb 2015 09:44:57 -0500
Message-ID: <CAF6AEGtBfr3fGEoFjFFpy1KrMJMZ-13VPPJX73fAkwiaLk+XGQ@mail.gmail.com>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints
 with dma-parms
From: Rob Clark <robdclark@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Vetter <daniel@ffwll.ch>

On Tue, Feb 3, 2015 at 9:37 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Tue, Feb 03, 2015 at 09:04:03AM -0500, Rob Clark wrote:
>> Since I'm stuck w/ an iommu, instead of built in mmu, my plan was to
>> drop use of dma-mapping entirely (incl the current call to dma_map_sg,
>> which I just need until we can use drm_cflush on arm), and
>> attach/detach iommu domains directly to implement context switches.
>> At that point, dma_addr_t really has no sensible meaning for me.
>
> So how do you intend to import from a subsystem which only gives you
> the dma_addr_t?
>
> If you aren't passing system memory, you have no struct page.  You can't
> fake up a struct page.  What this means is that struct scatterlist can't
> represent it any other way.

Tell the exporter to stop using carveouts, and give me proper memory
instead.. ;-)

Well, at least on these SoC's, I think the only valid use for carveout
memory is the bootloader splashscreen.  And I was planning on just
hanging on to that for myself for fbdev scanout buffer or other
internal (non shared) usage..

BR,
-R

> --
> FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
> according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
