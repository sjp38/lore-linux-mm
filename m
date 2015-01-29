Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id C6B976B006E
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 17:32:16 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id fb4so33436995wid.2
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 14:32:16 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id ys10si8823987wjc.129.2015.01.29.14.32.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 14:32:15 -0800 (PST)
Date: Thu, 29 Jan 2015 22:31:58 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150129223158.GF26493@n2100.arm.linux.org.uk>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
 <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
 <20150129143908.GA26493@n2100.arm.linux.org.uk>
 <CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
 <20150129154718.GB26493@n2100.arm.linux.org.uk>
 <CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
 <20150129192610.GE26493@n2100.arm.linux.org.uk>
 <CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <robdclark@gmail.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Jan 29, 2015 at 05:18:33PM -0500, Rob Clark wrote:
> On Thu, Jan 29, 2015 at 2:26 PM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > Now, if we're going to do the "more clever" thing you mention above,
> > that rather negates the point of this two-part patch set, which is to
> > provide the union of the DMA capabilities of all users.  A union in
> > that case is no longer sane as we'd be tailoring the SG lists to each
> > user.
> 
> It doesn't really negate.. a different sg list representing the same
> physical memory cannot suddenly make the buffer physically contiguous
> (from the perspective of memory)..
> 
> (unless we are not on the same page here, so to speak)

If we are really only interested in the "physically contiguous" vs
"scattered" differentiation, why can't this be just a simple flag?

I think I know where you're coming from on that distinction - most
GPUs can cope with their buffers being discontiguous in memory, but
scanout and capture hardware tends to need contiguous buffers.

My guess is that you're looking for some way that a GPU driver could
allocate a buffer, which can then be imported into the scanout
hardware - and when it is, the underlying backing store is converted
to a contiguous buffer.  Is that the usage scenario you're thinking
of?

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
