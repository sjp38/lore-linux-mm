Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 39E996B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 09:33:23 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id l15so24714435wiw.4
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 06:33:22 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id s3si43138667wjx.75.2015.02.03.06.33.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 06:33:21 -0800 (PST)
Date: Tue, 3 Feb 2015 14:32:59 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFCv3 2/2] dma-buf: add helpers for sharing attacher
 constraints with dma-parms
Message-ID: <20150203143258.GP8656@n2100.arm.linux.org.uk>
References: <CAO_48GEOQ1pBwirgEWeVVXW-iOmaC=Xerr2VyYYz9t1QDXgVsw@mail.gmail.com>
 <20150129154718.GB26493@n2100.arm.linux.org.uk>
 <CAF6AEGtTmFg66TK_AFkQ-xp7Nd9Evk3nqe6xCBp7K=77OmXTxA@mail.gmail.com>
 <20150129192610.GE26493@n2100.arm.linux.org.uk>
 <CAF6AEGujk8UC4X6T=yhTrz1s+SyZUQ=m05h_WcxLDGZU6bydbw@mail.gmail.com>
 <20150202165405.GX14009@phenom.ffwll.local>
 <CAF6AEGuESM+e3HSRGM6zLqrp8kqRLGUYvA3KKECdm7m-nt0M=Q@mail.gmail.com>
 <20150203074856.GF14009@phenom.ffwll.local>
 <20150203122813.GN8656@n2100.arm.linux.org.uk>
 <CAH9NwWcJRtNz1zAOmdjPN15UHPGiqGg9wNC9z3fMe-qn5ymdpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH9NwWcJRtNz1zAOmdjPN15UHPGiqGg9wNC9z3fMe-qn5ymdpA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Gmeiner <christian.gmeiner@gmail.com>
Cc: Daniel Vetter <daniel@ffwll.ch>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Robin Murphy <robin.murphy@arm.com>, LKML <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Tue, Feb 03, 2015 at 02:28:26PM +0100, Christian Gmeiner wrote:
> 2015-02-03 13:28 GMT+01:00 Russell King - ARM Linux <linux@arm.linux.org.uk>:
> > What I've found with *my* etnaviv drm implementation (not Christian's - I
> > found it impossible to work with Christian, especially with the endless
> > "msm doesn't do it that way, so we shouldn't" responses and his attitude
> > towards cherry-picking my development work [*]) is that it's much easier to
> > keep the GPU MMU local to the GPU and under the control of the DRM MM code,
> > rather than attaching the IOMMU to the DMA API and handling it that way.
> >
> 
> Keep in mind that I tried to reach you several times via mail and irc
> and you simply
> ignored me. Did you know that took almost all of your patches (with
> small changes)?
> And I needed to cherry pick you patches as they were a) wrong, b) solved in a
> different way or c) had "hack" in the subject. I am quite sorry that I
> ended that
> way, but it is not only my fault!

Exactly - you *took* every patch that I published whether I was ready
for you to take it or not.

That's not how kernel development works.  Kernel development works by
people working on the code, and *pushing* patches or git trees upstream.
It doesn't work by having people running around *taking* patches from
people just because they feel like it.

I asked you several times not to do that which means the only way I can
control you is by *not* publishing my changes, thereby denying other
people the ability to test my changes.

Another result of you *taking* patches from me is that you totally
*screwed* my ability to work with you.  If you make this stuff
unnecessary hard, you can expect people to walk away, and that's
precisely what I've done.

There's also the issue of you *taking* my patches and then applying
them to your tree with your own modifications, again *screwing* my tree,
and screwing my ability - again - to work with you.

Many of my patches in your repository are also marked as you being the
author of them... which _really_ is not nice.

Your "review" comments of "based 1:1 on the MSM driver" were really crazy.
Just because one DRM driver does something one way does not make it the
only way, nor does it make it suitable for use everywhere, even if you
modelled your driver on MSM.  It certainly doesn't mean that the way the
MSM driver does it is correct either.

And frankly, you calling my patches "wrong" is laughable.  I have a stable
fully functional Xorg DDX driver here which works with my version of your
etnaviv DRM across several Vivante GPUs - GC660 on Dove, and two revisions
of GC320 on iMX6 (which are notoriously buggy).  No kernel oopses, no GPU
lockups.  I've had machines with uptimes of a month here with it, with the
driver being exercised frequently during that period.

You refused to take things such as the DMA address monitoring for GPU
hangups to stop it mis-firing.  This _is_ a bug fix.  Without that, your
driver spits out random GPU hangups when there isn't actually any hangup
at all.  *Reliably* so.  Your excuse for not taking it was "The current
vivante driver doesn't do that."  While that's true, the V2 Vivante
drivers _do_ do it in their "guard thread" - and they do it because -
as I already explained to you - it's entirely possible for the GPU to
take a long time, longer than your hangcheck timeout, to render a
series of 1080p operations.  And again, not everything that the Vivante
drivers do is correct either.  Jon and myself know that very well having
spent a long time debugging their GPL'd offerings.

Even the "hack" patch was mostly correct - the reason that it is labelled
as a "hack" is because - as the commit log said - it should really be
done by the MMUv1 code, but that requires your entire IOMMU _bodge_ to be
rewritten properly.  Even the Vivante drivers use that region when they
can.

Then there's also the compatibility with the etnaviv library - which is
an important thing if you want people to make use of your driver.  You
applied the patches for and then reverted which completely screws the
Xorg DDX driver, making it impossible to support both etnaviv and
etnadrm without having two almost identical copies of the same code.  I
don't want to maintain almost identical copies of that same code, and
no one in their right mind would want that.

Having some level of sane user compatibility between etnaviv and
etnaviv drm will _gain_ you uses as it will allow people to write code
which works on both platforms - and it's really not difficult to do.
(In fact, I've proven it by writing a shim layer between the etnaviv
API and the DRM interfaces in the DDX driver.)

Then there's the round-robin IOMMU address space allocation, which is
required to avoid corrupted pixmaps (which is something that _your_
driver does very very well - in fact, so well that it corrupts system
memory), and the reaping of the IOMMU space when we run out of IOMMU
space to map.

Now, on to things that you do wrong.

There's your bodge with the component helper too which I'm disgusted with,
and I'll tell you now - your use of the component helper is wrong.

In your latest repository, there's this reserved-memory thing which you've
invented - to work around iMX6 with 2GB of RAM allocating the command
ring buffer at physical addresses >= 0x80000000.  That's absolutely not
necessary, the GPU has physical offset registers which can be used to
program the lower 2G of MMUv1 space at the appropriate offset - and
there's good reasons to do that - it prevents the GPU being able to
access 0x00000000-0x10000000 which are where the peripheral registers
are on the iMX6 - it prevents the GPU being able to scribble into (eg)
the SDRAM controller registers etc potentially taking the system down.
Yes, it won't work if we see 3G on iMX6, but that's something which can
be addressed in other ways (such as passing appropriate GFP_* flags.)

Here's a reminder of the kind of "high quality" review comments you
provided:

* staging: etnaviv: ensure cleanup of reservation object
commit 729b31a8dd07d5db744cc5cb32c28ebf2e8cadb5

This is based 1:1 on msm drm driver. I will talk with Rob
about it and will postpone this patch.

* staging: etnaviv: implement MMU reaping
commit 0c7f0736cc02ba83dea15d73e9fa98277839ca67

I will _NOT_ take this one.

* staging: etnaviv: stop the hangcheck timer mis-firing
commit f0c3d8f2bf81774aaf19284ec3287e343a772e63

Too hacky, current vivante drivers do not have this hack.
I will _NOT_ take this one.

* staging: etnaviv: increase iommu page table size to 512KiB
commit 610da4c465732f1c20495f8d7d9504ec25665bb0

I will _NOT_ take this one. I will postpone it.

* staging: etnaviv: fix fence wrapping for gem objects
commit 218e8ffce1d57a797e7f3234cd8ffd62fc4dab71

This is based 1:1 on msm drm driver. I will talk with Rob
about it and will postpone this patch.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
