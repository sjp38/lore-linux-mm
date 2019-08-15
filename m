Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60D22C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 12:53:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDDE0208C2
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 12:53:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="cQGnutdO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDDE0208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42F796B0275; Thu, 15 Aug 2019 08:53:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B9546B0276; Thu, 15 Aug 2019 08:53:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27FFC6B0277; Thu, 15 Aug 2019 08:53:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0131.hostedemail.com [216.40.44.131])
	by kanga.kvack.org (Postfix) with ESMTP id 00FFB6B0275
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 08:53:15 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 982AC8248AA2
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:53:15 +0000 (UTC)
X-FDA: 75824652750.08.rest93_569cde5e3f51e
X-HE-Tag: rest93_569cde5e3f51e
X-Filterd-Recvd-Size: 7744
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:53:15 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id u190so1700796qkh.5
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 05:53:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fsjt4TH+C2jg5iRhddzc9X6b3PVGQt0GzJbT4+qTTks=;
        b=cQGnutdO0QYQIDqcrjKN5BavYsdcncw1zhfeROmvdu2Z+fNKnqUDT9Wjf0ZaC8+woY
         mA49R7yqHlsDyNq8SRnGzLNHTofoK9KeXLxCWCZ7bxFVXOg+VnWX1x4qivFyvZAPyLJv
         DkXZY75TD9L6FZeyzvaFaQX7mLon/xcopirlW0lsbXvyjx4+a563K5NQePEDDrpDSDzR
         XN3zdVxH1b4lDhDhp+UWdgbSsNNWkQMD1SD0VxNuoESSSsnXVC3JHbDnovZyn0AVDbha
         D6XTUwcSHCVhYpCGX9W5LVcIeR5TUa2A+V/UpZUi7LpQqwDAdORerckHT1WetGPAVJJS
         HkjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=fsjt4TH+C2jg5iRhddzc9X6b3PVGQt0GzJbT4+qTTks=;
        b=P5tkI5dbzooph+8jrp2wMhik0qzbxKxHrlmfAt188vBBg8U1ObUXHXR/ftts48xbjI
         VTKVcP9Fvu6Fi0JtHAiD6EOY/ohIM5J/HfssT4SuaAYgR1yGf3N/o99NMakmhBZGfG5l
         vOZqamkTcV1lANVBqINeM5Nd8VcslTvjtNlQ41kW4WrIfe1i9OsqFTyv2FAdmVrkMS8c
         Izk4DvOYPAH6MGvpwf/Au/IMiA3HjhO4V+FNosyqIvGEKix6X9djJpd1o9JVYYXvA+ir
         ptUIlHUVfRmuhUR52oymTtda36Jz1jQAIaMUiAIyHvxGOcqvBoQLzmjZqYuXe+VjWJN2
         yd+w==
X-Gm-Message-State: APjAAAVPfHVY969X94YMVwiBBxBk1I26RDtEtJ/zcOEkeqe+42X/Zony
	wk9fDRCJTfnnOIqhzWCv2PxSMQ==
X-Google-Smtp-Source: APXvYqzxadEVjz9zg9VAEExmW6NU01W2O/jedDj26RcK9MXYxH1BLTItzBlbTSuXQVQiYwDGXzxPoQ==
X-Received: by 2002:a05:620a:691:: with SMTP id f17mr3965584qkh.470.1565873594583;
        Thu, 15 Aug 2019 05:53:14 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s28sm1351035qkm.5.2019.08.15.05.53.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 05:53:14 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyFFh-0004DD-D7; Thu, 15 Aug 2019 09:53:13 -0300
Date: Thu, 15 Aug 2019 09:53:13 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/5] mm, notifier: Add a lockdep map for
 invalidate_range_start
Message-ID: <20190815125313.GC21596@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-5-daniel.vetter@ffwll.ch>
 <20190815000959.GD11200@ziepe.ca>
 <20190815071014.GC7444@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815071014.GC7444@phenom.ffwll.local>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 09:10:14AM +0200, Daniel Vetter wrote:
> On Wed, Aug 14, 2019 at 09:09:59PM -0300, Jason Gunthorpe wrote:
> > On Wed, Aug 14, 2019 at 10:20:26PM +0200, Daniel Vetter wrote:
> > > This is a similar idea to the fs_reclaim fake lockdep lock. It's
> > > fairly easy to provoke a specific notifier to be run on a specific
> > > range: Just prep it, and then munmap() it.
> > > 
> > > A bit harder, but still doable, is to provoke the mmu notifiers for
> > > all the various callchains that might lead to them. But both at the
> > > same time is really hard to reliable hit, especially when you want to
> > > exercise paths like direct reclaim or compaction, where it's not
> > > easy to control what exactly will be unmapped.
> > > 
> > > By introducing a lockdep map to tie them all together we allow lockdep
> > > to see a lot more dependencies, without having to actually hit them
> > > in a single challchain while testing.
> > > 
> > > Aside: Since I typed this to test i915 mmu notifiers I've only rolled
> > > this out for the invaliate_range_start callback. If there's
> > > interest, we should probably roll this out to all of them. But my
> > > undestanding of core mm is seriously lacking, and I'm not clear on
> > > whether we need a lockdep map for each callback, or whether some can
> > > be shared.
> > 
> > I was thinking about doing something like this..
> > 
> > IMHO only range_end needs annotation, the other ops are either already
> > non-sleeping or only used by KVM.
>
> This isnt' about sleeping, this is about locking loops. And the biggest
> risk for that is from driver code, and at least hmm_mirror only has the
> driver code callback on invalidate_range_start. Once thing I discovered
> using this (and it would be really hard to spot, it's deeply neested) is
> that i915 userptr.

Sorry, that came out wrong, what I ment is that only range_end and
range_start really need annotation.

The other places are only used by KVM and are called in non-sleeping
contexts, so they already can't recurse back onto the popular sleeping
locks like mmap_sem or what not, can't do allocations, etc.  I don't
see alot of return in investing in them.

> > BTW, I have found it strange that i915 only uses
> > invalidate_range_start. Not really sure how it is able to do
> > that. Would love to know the answer :)
> 
> I suspect it's broken :-/ Our userptr is ... not the best. Part of the
> motivation here.

I was wondering if it is what we call in RDMA a 'registration cache'
ie you assume that userspace is well behaved while DMA is ongoing and
just use the notifer to invalidate cached dma mappings.

The hallmark of this pattern is that it holds the page pin the entire
time DMA is active, which is why it isn't a bug, it is just best
described as loosely coherent.

But, in RDMA the best-practice is to do this in userspace with
userfaultfd as it is very expensive to take a syscall on command
submission to have the kernel figure it out.

> > And if we do decide on the reclaim thing in my other email then the
> > reclaim dependency can be reliably injected by doing:
> > 
> >  fs_reclaim_acquire();
> >  lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
> >  lock_map_release(&__mmu_notifier_invalidate_range_start_map);
> >  fs_reclaim_release();
> > 
> > If I understand lockdep properly..
> 
> Ime fs_reclaim injects the mmu_notifier map here reliably as soon as
> you've thrown out the first pagecache mmap on any process. That "make sure
> we inject it quickly" is why the lockdep is _outside_ of the
> mm_has_notifiers() check. So no further injection needed imo.

I suspect a lot of our automated testing, like syzkaller in restricted
kvms, probably does not reliably trigger a fs_reclaim, so I would very
much prefer to inject it 100% of the time directly if we are sure this
is a reclaim context because of the i_mmap_rwsem I mentioned before.

Jason

