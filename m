Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FFE2C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:22:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB70D2084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:22:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="DW8d7upH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB70D2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ABE66B02E4; Thu, 15 Aug 2019 13:22:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75CEA6B02E6; Thu, 15 Aug 2019 13:22:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64C056B02E7; Thu, 15 Aug 2019 13:22:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0086.hostedemail.com [216.40.44.86])
	by kanga.kvack.org (Postfix) with ESMTP id 469826B02E4
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:22:01 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 034D38248AAD
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:22:01 +0000 (UTC)
X-FDA: 75825330042.07.money31_68d63d441034e
X-HE-Tag: money31_68d63d441034e
X-Filterd-Recvd-Size: 8375
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com [209.85.210.65])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:22:00 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id r20so7150007ota.5
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:22:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IneA/NByuov1/wIWEDzX2u+XtXERMrXayHKFhJ+HiY4=;
        b=DW8d7upHOzxtkb8qPMBczW68kx2wDiXvN/uCio1qHyvbYXa22blzcVmidO4Q0OtH17
         bla0ds6vchbl+QpN/bMqBBbQsh57wTyjFAznEuU9i3Y+612QFgvQ7WUEP80tg+YhzF3l
         q5MiWXjguzBAr2g9rFa7BDyXQZQ3eUe4QPsAA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=IneA/NByuov1/wIWEDzX2u+XtXERMrXayHKFhJ+HiY4=;
        b=hB37GFBnbvZU0P3B/KHSl1INjE+pJDFy8fBQe2priUCSDG3cQsDEvDrnN07apaLiSP
         5uuWEi/rsn2/j18zzDufoEe/PXn0enC2Fa7uqD/56DGQh8rMvEvpQ0h/x1xW6vK9qvEj
         N22KCdVPOIUJY+pFXqfZQQ6Sl37Tdry88Yv4glpFuPiWrAtplPBQn+Skpgep5jT4Go9E
         1hoBW1EtqiIZjsKnRSHGYmIoDdcv1gmv3f6RhCPynd9hXSyH4G3f76sZSBfJ7ODAyvUC
         ih9bPDZfc64azdOI4+FS5/wp3dq+AUD7i9r+GjW7H8tCGwZ9Utx/z0R4uIpRozQmcLhq
         F1wg==
X-Gm-Message-State: APjAAAUo4abZoDKJhgCDP1+EnEo0DhGk2R1Aer0N5pBYwxJdcZHK0kf/
	VGUqMjcFclsZzrflM5QxdComJKYLToKMQ4QaBCf1AA==
X-Google-Smtp-Source: APXvYqxAO9I+FQI3wMSOWr5DBrm2g5rp4Janm9JCmIoZw4652WqL6bZMI//FiJeDximmJ85hIHKdrIsiGXHl27klNGw=
X-Received: by 2002:a9d:7cc9:: with SMTP id r9mr4642730otn.188.1565889719385;
 Thu, 15 Aug 2019 10:21:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch> <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz> <20190815130415.GD21596@ziepe.ca>
 <CAKMK7uE9zdmBuvxa788ONYky=46GN=5Up34mKDmsJMkir4x7MQ@mail.gmail.com>
 <20190815143759.GG21596@ziepe.ca> <CAKMK7uEJQ6mPQaOWbT_6M+55T-dCVbsOxFnMC6KzLAMQNa-RGg@mail.gmail.com>
 <20190815151028.GJ21596@ziepe.ca> <20190815163238.GA30781@redhat.com> <20190815171622.GL21596@ziepe.ca>
In-Reply-To: <20190815171622.GL21596@ziepe.ca>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Thu, 15 Aug 2019 19:21:47 +0200
Message-ID: <CAKMK7uGm_vg_6sqU2X=Owu79zLcC8d5U+Yr2O-oEsCnTjeWzCw@mail.gmail.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, DRI Development <dri-devel@lists.freedesktop.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Peter Zijlstra <peterz@infradead.org>, 
	Ingo Molnar <mingo@redhat.com>, David Rientjes <rientjes@google.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Wei Wang <wvw@google.com>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Jann Horn <jannh@google.com>, Feng Tang <feng.tang@intel.com>, 
	Kees Cook <keescook@chromium.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Daniel Vetter <daniel.vetter@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 7:16 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Thu, Aug 15, 2019 at 12:32:38PM -0400, Jerome Glisse wrote:
> > On Thu, Aug 15, 2019 at 12:10:28PM -0300, Jason Gunthorpe wrote:
> > > On Thu, Aug 15, 2019 at 04:43:38PM +0200, Daniel Vetter wrote:
> > >
> > > > You have to wait for the gpu to finnish current processing in
> > > > invalidate_range_start. Otherwise there's no point to any of this
> > > > really. So the wait_event/dma_fence_wait are unavoidable really.
> > >
> > > I don't envy your task :|
> > >
> > > But, what you describe sure sounds like a 'registration cache' model,
> > > not the 'shadow pte' model of coherency.
> > >
> > > The key difference is that a regirstationcache is allowed to become
> > > incoherent with the VMA's because it holds page pins. It is a
> > > programming bug in userspace to change VA mappings via mmap/munmap/etc
> > > while the device is working on that VA, but it does not harm system
> > > integrity because of the page pin.
> > >
> > > The cache ensures that each initiated operation sees a DMA setup that
> > > matches the current VA map when the operation is initiated and allows
> > > expensive device DMA setups to be re-used.
> > >
> > > A 'shadow pte' model (ie hmm) *really* needs device support to
> > > directly block DMA access - ie trigger 'device page fault'. ie the
> > > invalidate_start should inform the device to enter a fault mode and
> > > that is it.  If the device can't do that, then the driver probably
> > > shouldn't persue this level of coherency. The driver would quickly get
> > > into the messy locking problems like dma_fence_wait from a notifier.
> >
> > I think here we do not agree on the hardware requirement. For GPU
> > we will always need to be able to wait for some GPU fence from inside
> > the notifier callback, there is just no way around that for many of
> > the GPUs today (i do not see any indication of that changing).
>
> I didn't say you couldn't wait, I was trying to say that the wait
> should only be contigent on the HW itself. Ie you can wait on a GPU
> page table lock, and you can wait on a GPU page table flush completion
> via IRQ.
>
> What is troubling is to wait till some other thread gets a GPU command
> completion and decr's a kref on the DMA buffer - which kinda looks
> like what this dma_fence() stuff is all about. A driver like that
> would have to be super careful to ensure consistent forward progress
> toward dma ref == 0 when the system is under reclaim.
>
> ie by running it's entire IRQ flow under fs_reclaim locking.

This is correct. At least for i915 it's already a required due to our
shrinker also having to do the same. I think amdgpu isn't bothering
with that since they have vram for most of the stuff, and just limit
system memory usage to half of all and forgo the shrinker. Probably
not the nicest approach. Anyway, both do the same mmu_notifier dance,
just want to explain that we've been living with this for longer
already.

So yeah writing a gpu driver is not easy.

> > associated with the mm_struct. In all GPU driver so far it is a short
> > lived lock and nothing blocking is done while holding it (it is just
> > about updating page table directory really wether it is filling it or
> > clearing it).
>
> The main blocking I expect in a shadow PTE flow is waiting for the HW
> to complete invalidations of its PTE cache.
>
> > > It is important to identify what model you are going for as defining a
> > > 'registration cache' coherence expectation allows the driver to skip
> > > blocking in invalidate_range_start. All it does is invalidate the
> > > cache so that future operations pick up the new VA mapping.
> > >
> > > Intel's HFI RDMA driver uses this model extensively, and I think it is
> > > well proven, within some limitations of course.
> > >
> > > At least, 'registration cache' is the only use model I know of where
> > > it is acceptable to skip invalidate_range_end.
> >
> > Here GPU are not in the registration cache model, i know it might looks
> > like it because of GUP but GUP was use just because hmm did not exist
> > at the time.
>
> It is not because of GUP, it is because of the lack of
> invalidate_range_end. A driver cannot correctly implement the SPTE
> model without invalidate_range_end, even if it holds the page pins via
> GUP.
>
> So, I've been assuming the few drivers without invalidate_range_end
> are trying to do registration caching, rather than assuming they are
> broken.

I915 might just be broken. amdgpu does the full thing, using
hmm_mirror. But still with dma_fence_wait.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

