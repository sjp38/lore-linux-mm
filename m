Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E177CC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:20:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D8A5222C0
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:20:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D8A5222C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D5A68E0004; Tue, 12 Feb 2019 12:20:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4859D8E0001; Tue, 12 Feb 2019 12:20:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39C6F8E0004; Tue, 12 Feb 2019 12:20:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA81A8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:20:25 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id q20so2689318pls.4
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:20:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x9UTPLTa8dCUVWJRiKQvzNuVzgwlcxyp2SfRhYbH69o=;
        b=mN79JD0t6aDeJvyuOkU46i4lvY9Zf8yFavfDx9YtW+edCM2sLBtOjXC+fJrnRS90Ew
         3XVMadzGhEH8ajo5E0T0Ql+GwxHcrLwImMUm/cQahJn67FB1VTCjZyHuS7qavgpM7ort
         VNDgVVQt3aGChAi4ElDb7mWX/7wpQAscJWBfUVyNhpQ9UGlNaVHQdQfGFJqJtJ0SQo9Q
         3Jz9CnFP5KifdiBXMmwjCYHQ7CGgSJH30fhsSIc/0k/WDYpzE0IQGI8ccds5pd1qWClW
         iTRzUdgn2Xw1FzQDHUpgflQuLoslU2M1L47siMO90I8P2C2446HCeTHsncj/3Q8ytV38
         14Kw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYytF5OSsJEQ/9Ia9epTOTxS5ejeEOj+6LeIbrzUdjq4tD2n9cW
	Wq8ZWI9uPOwyr8XtApyE6w1l42+pEtgajlDUaEODY9iSZAqKOA258K54DwknuejNVEFSc0Yn+Fp
	uaNZhGKpThz2hJWgm2sKvQQmHakORaZNSXOrzIO4USZFdB3INHt//7zzxwTE09R10Hg==
X-Received: by 2002:a63:4005:: with SMTP id n5mr4496909pga.86.1549992025600;
        Tue, 12 Feb 2019 09:20:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbGlTBL0vUa2n2t5Xv0v5cR5+GwzpJLGPAGlGxTbfZJm3brH9ziyxXulmUmr9fiFzBqWZh8
X-Received: by 2002:a63:4005:: with SMTP id n5mr4496841pga.86.1549992024572;
        Tue, 12 Feb 2019 09:20:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549992024; cv=none;
        d=google.com; s=arc-20160816;
        b=FqS7DPi2Xp0ljCOaTNkca8QH3yxKU+aImvgCprbCNw9yl1GBqlN41180N/v9SbhnTw
         qujZPNEX65jr4iO0eU/+S4rrwKwDbhFGmN7DUkdhLa/P7NP+2lPiQvBvUA1G16UkIPkG
         1Ws02wQwAUzRIQFRFwQ8CcgLYGTAHKhLArgtPMFo1qQqx1kTYkDV4L782lOLBbxm7Jg6
         sGVz1WUPTfnHKscPgyxXUG/rZ9ErHlBWgzTQ8eqYoWEpihBd62uACsyXp7MVSYvALV+1
         9Ksh+MeFBRMKfIXmRvKpLOUwolkfxmEGjKMLXbjTXIAG7x9YGZjyAS+6EcD/+23ewBSd
         /8uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=x9UTPLTa8dCUVWJRiKQvzNuVzgwlcxyp2SfRhYbH69o=;
        b=FAG921ZVuPZs8oIwCupxohkcKMRnnwaslG1H//sAJKxns5//sDp0e/GRZ2IcJjJJtU
         ppJcBocI/LDyET3FYgNp1zWtWuIPvJfqqNPc9QoMKYXpxNau/IEubS/2bm7gopBjERmj
         V51xFiMrxwd6LN2AJ85/LZXa1zE1Vd9lyDHU22gNHr1v23jgeD8zhd5JrrT7axlTWClL
         3Sm/Sz7yFqFAPJ6AcKlU5bM/jT/9opxK6nQWeNmL11kQtqAyEwGnUW0yQCWJhPDj81Hd
         2hPUZBaCDdi5hiL5LplkQCT2kWHeIgmDRlSn59SFgIWjoqUmFPLvn8tPzzL1SAVzHcQ+
         38dw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id h7si11177797pgp.49.2019.02.12.09.20.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 09:20:24 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Feb 2019 09:20:23 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,362,1544515200"; 
   d="scan'208";a="115638066"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga006.jf.intel.com with ESMTP; 12 Feb 2019 09:20:23 -0800
Message-ID: <0963dd4b3256265160d7104e256aa606fb3f9519.camel@linux.intel.com>
Subject: Re: [RFC PATCH 4/4] mm: Add merge page notifier
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Aaron Lu <aaron.lwe@gmail.com>, Alexander Duyck
 <alexander.duyck@gmail.com>,  linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de, 
 hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org
Date: Tue, 12 Feb 2019 09:20:23 -0800
In-Reply-To: <ead37c94-4703-170f-0ff4-1bb171556775@gmail.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181558.12095.83484.stgit@localhost.localdomain>
	 <5e6d22b2-0f14-43eb-846b-a940e629c02b@gmail.com>
	 <a5b698b0f85667dba9b949dcb6e65a0d806669de.camel@linux.intel.com>
	 <ead37c94-4703-170f-0ff4-1bb171556775@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-02-12 at 10:09 +0800, Aaron Lu wrote:
> On 2019/2/11 23:58, Alexander Duyck wrote:
> > On Mon, 2019-02-11 at 14:40 +0800, Aaron Lu wrote:
> > > On 2019/2/5 2:15, Alexander Duyck wrote:
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > 
> > > > Because the implementation was limiting itself to only providing hints on
> > > > pages huge TLB order sized or larger we introduced the possibility for free
> > > > pages to slip past us because they are freed as something less then
> > > > huge TLB in size and aggregated with buddies later.
> > > > 
> > > > To address that I am adding a new call arch_merge_page which is called
> > > > after __free_one_page has merged a pair of pages to create a higher order
> > > > page. By doing this I am able to fill the gap and provide full coverage for
> > > > all of the pages huge TLB order or larger.
> > > > 
> > > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > ---
> > > >  arch/x86/include/asm/page.h |   12 ++++++++++++
> > > >  arch/x86/kernel/kvm.c       |   28 ++++++++++++++++++++++++++++
> > > >  include/linux/gfp.h         |    4 ++++
> > > >  mm/page_alloc.c             |    2 ++
> > > >  4 files changed, 46 insertions(+)
> > > > 
> > > > diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> > > > index 4487ad7a3385..9540a97c9997 100644
> > > > --- a/arch/x86/include/asm/page.h
> > > > +++ b/arch/x86/include/asm/page.h
> > > > @@ -29,6 +29,18 @@ static inline void arch_free_page(struct page *page, unsigned int order)
> > > >  	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> > > >  		__arch_free_page(page, order);
> > > >  }
> > > > +
> > > > +struct zone;
> > > > +
> > > > +#define HAVE_ARCH_MERGE_PAGE
> > > > +void __arch_merge_page(struct zone *zone, struct page *page,
> > > > +		       unsigned int order);
> > > > +static inline void arch_merge_page(struct zone *zone, struct page *page,
> > > > +				   unsigned int order)
> > > > +{
> > > > +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> > > > +		__arch_merge_page(zone, page, order);
> > > > +}
> > > >  #endif
> > > >  
> > > >  #include <linux/range.h>
> > > > diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> > > > index 09c91641c36c..957bb4f427bb 100644
> > > > --- a/arch/x86/kernel/kvm.c
> > > > +++ b/arch/x86/kernel/kvm.c
> > > > @@ -785,6 +785,34 @@ void __arch_free_page(struct page *page, unsigned int order)
> > > >  		       PAGE_SIZE << order);
> > > >  }
> > > >  
> > > > +void __arch_merge_page(struct zone *zone, struct page *page,
> > > > +		       unsigned int order)
> > > > +{
> > > > +	/*
> > > > +	 * The merging logic has merged a set of buddies up to the
> > > > +	 * KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER. Since that is the case, take
> > > > +	 * advantage of this moment to notify the hypervisor of the free
> > > > +	 * memory.
> > > > +	 */
> > > > +	if (order != KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
> > > > +		return;
> > > > +
> > > > +	/*
> > > > +	 * Drop zone lock while processing the hypercall. This
> > > > +	 * should be safe as the page has not yet been added
> > > > +	 * to the buddy list as of yet and all the pages that
> > > > +	 * were merged have had their buddy/guard flags cleared
> > > > +	 * and their order reset to 0.
> > > > +	 */
> > > > +	spin_unlock(&zone->lock);
> > > > +
> > > > +	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
> > > > +		       PAGE_SIZE << order);
> > > > +
> > > > +	/* reacquire lock and resume freeing memory */
> > > > +	spin_lock(&zone->lock);
> > > > +}
> > > > +
> > > >  #ifdef CONFIG_PARAVIRT_SPINLOCKS
> > > >  
> > > >  /* Kick a cpu by its apicid. Used to wake up a halted vcpu */
> > > > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > > > index fdab7de7490d..4746d5560193 100644
> > > > --- a/include/linux/gfp.h
> > > > +++ b/include/linux/gfp.h
> > > > @@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
> > > >  #ifndef HAVE_ARCH_FREE_PAGE
> > > >  static inline void arch_free_page(struct page *page, int order) { }
> > > >  #endif
> > > > +#ifndef HAVE_ARCH_MERGE_PAGE
> > > > +static inline void
> > > > +arch_merge_page(struct zone *zone, struct page *page, int order) { }
> > > > +#endif
> > > >  #ifndef HAVE_ARCH_ALLOC_PAGE
> > > >  static inline void arch_alloc_page(struct page *page, int order) { }
> > > >  #endif
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index c954f8c1fbc4..7a1309b0b7c5 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -913,6 +913,8 @@ static inline void __free_one_page(struct page *page,
> > > >  		page = page + (combined_pfn - pfn);
> > > >  		pfn = combined_pfn;
> > > >  		order++;
> > > > +
> > > > +		arch_merge_page(zone, page, order);
> > > 
> > > Not a proper place AFAICS.
> > > 
> > > Assume we have an order-8 page being sent here for merge and its order-8
> > > buddy is also free, then order++ became 9 and arch_merge_page() will do
> > > the hint to host on this page as an order-9 page, no problem so far.
> > > Then the next round, assume the now order-9 page's buddy is also free,
> > > order++ will become 10 and arch_merge_page() will again hint to host on
> > > this page as an order-10 page. The first hint to host became redundant.
> > 
> > Actually the problem is even worse the other way around. My concern was
> > pages being incrementally freed.
> > 
> > With this setup I can catch when we have crossed the threshold from
> > order 8 to 9, and specifically for that case provide the hint. This
> > allows me to ignore orders above and below 9.
> 
> OK, I see, you are now only hinting for pages with order 9, not above.

Right.

> > If I move the hint to the spot after the merging I have no way of
> > telling if I have hinted the page as a lower order or not. As such I
> > will hint if it is merged up to orders 9 or greater. So for example if
> > it merges up to order 9 and stops there then done_merging will report
> > an order 9 page, then if another page is freed and merged with this up
> > to order 10 you would be hinting on order 10. By placing the function
> > here I can guarantee that no more than 1 hint is provided per 2MB page.
> 
> So what's the downside of hinting the page as order-10 after merge
> compared to as order-9 before the merge? I can see the same physical
> range can be hinted multiple times, but the total hint number is the
> same: both are 2 - in your current implementation, we hint twice for
> each of the 2 order-9 pages; alternatively, we can provide hint for one
> order-9 page and the merged order-10 page. I think the cost of
> hypercalls are the same? Is it that we want to ease the host side
> madvise(DONTNEED) since we can avoid operating the same range multiple
> times?

The cost for the hypercall overhead is the same, but I would think you
are in the hypercall a bit longer for the order 10 page because you are
having to process both order 9 pages in order clear them. In my mind
doing it that way you end up having to do 50% more madvise work. For a
THP based setup it probably isn't an issue, but I would think if we are
having to invalidate things at the 4K page level that cost could add up
real quick.

I could probably try launching the guest with THP disabled in QEMU to
verify if the difference is visible or not.

> The reason I asked is, if we can move the arch_merge_page() after
> done_merging tag, we can theoretically make fewer function calls on free
> path for the guest. Maybe not a big deal, I don't know...

I suspect it really isn't that big a deal. The two functions are
essentially inline and only one will ever make use of the hypercall.

> > > I think the proper place is after the done_merging tag.
> > > 
> > > BTW, with arch_merge_page() at the proper place, I don't think patch3/4
> > > is necessary - any freed page will go through merge anyway, we won't
> > > lose any hint opportunity. Or do I miss anything?
> > 
> > You can refer to my comment above. What I want to avoid is us hinting a
> > page multiple times if we aren't using MAX_ORDER - 1 as the limit. What
> 
> Yeah that's a good point. But is this going to happen?

One of the advantages I have from splitting things out the way I did is
that I have been able to add some debug counters to track what is freed
as a higher order page and what isn't. From what I am seeing after boot
essentially all of the calls are coming from the merge logic.

I'm suspecting the typical use case is that pages are likely going to
either be freed as something THP or larger, or they will be freed in 4K
increments. By splitting things up the way I did we end up getting the
most efficient performance out of the 4K case since we avoid performing
madvise 1.5 times per page and keep it to once per page.

