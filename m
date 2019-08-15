Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 952C8C3A59B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:16:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3040A21783
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:16:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="LyKrHHML"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3040A21783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF75A6B02DB; Thu, 15 Aug 2019 13:16:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA7686B02DC; Thu, 15 Aug 2019 13:16:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A94B76B02DD; Thu, 15 Aug 2019 13:16:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0132.hostedemail.com [216.40.44.132])
	by kanga.kvack.org (Postfix) with ESMTP id 837316B02DB
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:16:25 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 2F78E8248AAD
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:16:25 +0000 (UTC)
X-FDA: 75825315930.13.stage08_37fa75fc3e359
X-HE-Tag: stage08_37fa75fc3e359
X-Filterd-Recvd-Size: 8229
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:16:24 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id t12so3085794qtp.9
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:16:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bWQUZxVbgX8q+7/XNaaPkBz6uudNI37srtiH/YJRLMA=;
        b=LyKrHHML5qsAHOuu+3liATWbTb6DyVTWCsOvlxwJdwkXlE0Lc7JX8x425zP9bIasr/
         z234649hCY9AqF83cc5SAoIRaIGSRUwvwesHrGgGC/flGkruF6oA300ue/onshbs0F/i
         avAkH6M1hqae7FbSfWx+SXEeVdRgVe8bp9cLBXMdWZAUwtclZPY109M3LnNxQRmTehbp
         A7+xYYueXtM+21QPDvDrdSYFg/+07W6wRbHEVPua8v1p5B4JKdw3uruExAedVopc4WP7
         Joi5pFjarqFpfyVffxS7kdZQFyZ5RbTa72w3H2Rr5rdf2MgdFsBu794ulKvyqyrX+GuO
         iHvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=bWQUZxVbgX8q+7/XNaaPkBz6uudNI37srtiH/YJRLMA=;
        b=NNabi1K3wK13ZdLlW3pVogOlReCvG0dvP3T8HdffQ8A0eWb3+/lTTlpDASWxdzaJJq
         vXfyP/FN93zLljFWoedqacug1WAmMVNuDlSYx6Svh8f0lIhT2nEmtbtoCpsu7g6o8DW9
         /7E9i8QBS0ey+rQODJ2N02vBjOEgjuJNo4sCsyIjFamQEHfeJEIFWx0+e5E9vYoqhTom
         HUCId30yonn7IdyfduVBanhVO7d35NkvWszsoPdXbcb5tThWofI5sOTbgkZJHZy0Gurd
         PCn8VEE3qBJHVM8za/5jmL0Uj/vZJR0vpzkcjj0pwOXD76im0in99yet8d+RL51slSey
         L1cw==
X-Gm-Message-State: APjAAAUzCaYfkuSd3gBCB3kENnzZYBsVhIxIT3YgkNVvz+X4eHOPe3oC
	/qtSglilsQacHuzzh3V38XAiPg==
X-Google-Smtp-Source: APXvYqzhMs0H6HOINgldm0wqFeedn0yeVMbyJrKiVDfNKdY5nOzLsfj8OD4YZcVQ3nL9Fvat5g8RJg==
X-Received: by 2002:a0c:9d0d:: with SMTP id m13mr4071346qvf.174.1565889383869;
        Thu, 15 Aug 2019 10:16:23 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id l11sm1685225qtr.11.2019.08.15.10.16.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 10:16:23 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyJMM-0006lb-QQ; Thu, 15 Aug 2019 14:16:22 -0300
Date: Thu, 15 Aug 2019 14:16:22 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815171622.GL21596@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz>
 <20190815130415.GD21596@ziepe.ca>
 <CAKMK7uE9zdmBuvxa788ONYky=46GN=5Up34mKDmsJMkir4x7MQ@mail.gmail.com>
 <20190815143759.GG21596@ziepe.ca>
 <CAKMK7uEJQ6mPQaOWbT_6M+55T-dCVbsOxFnMC6KzLAMQNa-RGg@mail.gmail.com>
 <20190815151028.GJ21596@ziepe.ca>
 <20190815163238.GA30781@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815163238.GA30781@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 12:32:38PM -0400, Jerome Glisse wrote:
> On Thu, Aug 15, 2019 at 12:10:28PM -0300, Jason Gunthorpe wrote:
> > On Thu, Aug 15, 2019 at 04:43:38PM +0200, Daniel Vetter wrote:
> > 
> > > You have to wait for the gpu to finnish current processing in
> > > invalidate_range_start. Otherwise there's no point to any of this
> > > really. So the wait_event/dma_fence_wait are unavoidable really.
> > 
> > I don't envy your task :|
> > 
> > But, what you describe sure sounds like a 'registration cache' model,
> > not the 'shadow pte' model of coherency.
> > 
> > The key difference is that a regirstationcache is allowed to become
> > incoherent with the VMA's because it holds page pins. It is a
> > programming bug in userspace to change VA mappings via mmap/munmap/etc
> > while the device is working on that VA, but it does not harm system
> > integrity because of the page pin.
> > 
> > The cache ensures that each initiated operation sees a DMA setup that
> > matches the current VA map when the operation is initiated and allows
> > expensive device DMA setups to be re-used.
> > 
> > A 'shadow pte' model (ie hmm) *really* needs device support to
> > directly block DMA access - ie trigger 'device page fault'. ie the
> > invalidate_start should inform the device to enter a fault mode and
> > that is it.  If the device can't do that, then the driver probably
> > shouldn't persue this level of coherency. The driver would quickly get
> > into the messy locking problems like dma_fence_wait from a notifier.
> 
> I think here we do not agree on the hardware requirement. For GPU
> we will always need to be able to wait for some GPU fence from inside
> the notifier callback, there is just no way around that for many of
> the GPUs today (i do not see any indication of that changing).

I didn't say you couldn't wait, I was trying to say that the wait
should only be contigent on the HW itself. Ie you can wait on a GPU
page table lock, and you can wait on a GPU page table flush completion
via IRQ.

What is troubling is to wait till some other thread gets a GPU command
completion and decr's a kref on the DMA buffer - which kinda looks
like what this dma_fence() stuff is all about. A driver like that
would have to be super careful to ensure consistent forward progress
toward dma ref == 0 when the system is under reclaim. 

ie by running it's entire IRQ flow under fs_reclaim locking.

> associated with the mm_struct. In all GPU driver so far it is a short
> lived lock and nothing blocking is done while holding it (it is just
> about updating page table directory really wether it is filling it or
> clearing it).

The main blocking I expect in a shadow PTE flow is waiting for the HW
to complete invalidations of its PTE cache.

> > It is important to identify what model you are going for as defining a
> > 'registration cache' coherence expectation allows the driver to skip
> > blocking in invalidate_range_start. All it does is invalidate the
> > cache so that future operations pick up the new VA mapping.
> > 
> > Intel's HFI RDMA driver uses this model extensively, and I think it is
> > well proven, within some limitations of course.
> > 
> > At least, 'registration cache' is the only use model I know of where
> > it is acceptable to skip invalidate_range_end.
> 
> Here GPU are not in the registration cache model, i know it might looks
> like it because of GUP but GUP was use just because hmm did not exist
> at the time.

It is not because of GUP, it is because of the lack of
invalidate_range_end. A driver cannot correctly implement the SPTE
model without invalidate_range_end, even if it holds the page pins via
GUP.

So, I've been assuming the few drivers without invalidate_range_end
are trying to do registration caching, rather than assuming they are
broken.

Jason

