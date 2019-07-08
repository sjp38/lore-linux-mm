Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F244C606C7
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 19:03:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CD8021783
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 19:03:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CD8021783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D69B8E0033; Mon,  8 Jul 2019 15:03:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 888448E0032; Mon,  8 Jul 2019 15:03:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 702C08E0033; Mon,  8 Jul 2019 15:03:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 32F068E0032
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 15:03:02 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so9243681pld.15
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 12:03:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=6dSbsstm7D+ahazuzC4GhGVzXVN/bkZFnRzh9UJUT+8=;
        b=bpt37OFqGs82y/Wq3vPvAgDAoTdT0DBMdTfjKptcIcVJid1JZzzYgpdworM8pcdSuZ
         HX4ohdfpJR6mSqVIqhw3AUZsrcE/QPi4VMrbHAzvI9kZOAzH68FVcOSVV1rmIzKmFlmM
         d5rieXKNHkJcsieL2fljISCOS7nbm+JNxICoOPTwnixDpJ8IxS7dloWZRaJEozLU2XQr
         p+kdqun/Ovu3mTm0MvzWCx4Cgo4M/gJP4ZPl6gE8xT/zm2a6thNtgujMJdeaBpwZPvth
         qS7azi2xy9fhVP6lZI7Hgr+/R4DQAThig2Z4kbs7TUSMaXLMsuOCLqijTnmSoi3hzrJ+
         i9dQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUyoHyWmDcbv/A+nstKT3iYnRF3uH0hpwB7uSQ4wBB7PX5FhKnF
	34a1tpw/2YF0PpfF7JZFC2Iz7GQLYLI4sJ7vfqpWGyla3srls/zBO9TvfpF1FvmdB8Z5Q6L1Pws
	RacsCrVtZnhb8uIyvHoTCtW/8aOT0Jmg+NnBjbyb4ziwYvsoI2qFJLCC1SXZ86dlZMw==
X-Received: by 2002:a63:6155:: with SMTP id v82mr25354409pgb.304.1562612581604;
        Mon, 08 Jul 2019 12:03:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpZKAj/DkyPfsNURmDh8cYKxky/GgV6BCzIymr9d9576h2qy28r4GGvVFBvfbwyFww5wwe
X-Received: by 2002:a63:6155:: with SMTP id v82mr25354298pgb.304.1562612580117;
        Mon, 08 Jul 2019 12:03:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562612580; cv=none;
        d=google.com; s=arc-20160816;
        b=jNuM4tNKcGL91Evd9DHUdBwEfev4xVhvPygzMbVrkgTD9mjbIFJH4JzSEvbMFDxfbm
         7ce2D7w3OPcXSxSX3SHCzL4Fj93o6irEtysM2upzTX+MQ3SRlEtLpwFdnQ+ljmGPlL7q
         uiTQl+d0EWDBsyyiRh6e8t+hf2VnxoTGTmQjmzaELHriT1iHBkQGrLRJpu25BuSrmzTB
         ZDaX3KA25Vr7GUQLTRBmisAjG6YT1h/xpFPcDo9DFG0hWNjqMDms/7NzseoaV74Zsl0Q
         pHJ9ISphEFiD2vOfmsL3yVYHH1UG/0kBOvW73513p5aUqHiV9DB6O93JnjED3lt4XLDe
         kbyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=6dSbsstm7D+ahazuzC4GhGVzXVN/bkZFnRzh9UJUT+8=;
        b=mo1Z9p+31+n8PmhG+o5awvM9uKLx4JGQUjaVKUqELdz44na23yJQzB8KTkz3axnk0q
         afoY4UgnakR9UTZVZvYYgT1bJuZl2iAn4VknQO8tnpDakt3eJOd1fgABCycisO/2THPO
         jr8trTzl6tLoBK0Ww2dKG2OPTkIXLeJZSjiv0MzZS9j1ksxZeL2P/BI8YC5+0ue1i08k
         WwaR2yXfcArrSH0uCDrj3+N04JlRm+AwRFeX5pJju8/CCiV4qQVWq+3jF58ThqYIhNR+
         Y2uHEUO31Rhbl2LT/iFduJl9ilG7XhloQjlii+TjPv3L2qshsC8nmQ/ZFAykaIa+6VlT
         04nw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id g1si10261964pfi.139.2019.07.08.12.02.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 12:03:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Jul 2019 12:02:59 -0700
X-IronPort-AV: E=Sophos;i="5.63,466,1557212400"; 
   d="scan'208";a="248910138"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Jul 2019 12:02:58 -0700
Message-ID: <66a43ec2912265ff7f1a16e0cf5258d5c3c61de5.camel@linux.intel.com>
Subject: Re: [PATCH v1 5/6] mm: Add logic for separating "aerated" pages
 from "raw" pages
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Alexander Duyck
 <alexander.duyck@gmail.com>, nitesh@redhat.com, kvm@vger.kernel.org, 
 david@redhat.com, mst@redhat.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org,  akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, 
	konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com, 
	aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com
Date: Mon, 08 Jul 2019 12:02:58 -0700
In-Reply-To: <f704f160-49fb-2fdf-e8ac-44b47245a75c@intel.com>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
	 <20190619223331.1231.39271.stgit@localhost.localdomain>
	 <f704f160-49fb-2fdf-e8ac-44b47245a75c@intel.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-25 at 13:24 -0700, Dave Hansen wrote:
> On 6/19/19 3:33 PM, Alexander Duyck wrote:
> > Add a set of pointers we shall call "boundary" which represents the upper
> > boundary between the "raw" and "aerated" pages. The general idea is that in
> > order for a page to cross from one side of the boundary to the other it
> > will need to go through the aeration treatment.
> 
> Aha!  The mysterious "boundary"!
> 
> But, how can you introduce code that deals with boundaries before
> introducing the boundary itself?  Or was that comment misplaced?

The comment in the earlier patch was misplaced. Basically the logic before
this patch would just add the aerated pages directly to the tail of the
free_list, however if it had to leave and come back there was nothing to
prevent us from creating a mess of interleaved "raw" and "aerated" pages.
With this patch we are guaranteed that any "raw" pages are added above the
"aerated" pages and will be pulled for processing.

> FWIW, I'm not a fan of these commit messages.  They are really hard to
> map to the data structures.
> 
> 	One goal in this set is to avoid creating new data structures.
> 	We accomplish that by reusing the free lists to hold aerated and
> 	non-aerated pages.  But, in order to use the existing free list,
> 	we need a boundary to separate aerated from raw.
> 
> Further:
> 
> 	Pages are temporarily removed from the free lists while aerating
> 	them.
> 
> This needs a justification why you chose this path, and also what the
> larger implications are.

Well the big advantage is that we aren't messing with the individual
free_area or free_list structures. My initial implementation was adding a
third pointer to split do the work and it actually had performance
implications as it increased the size of the free_area and zone.

> > By doing this we should be able to make certain that we keep the aerated
> > pages as one contiguous block on the end of each free list. This will allow
> > us to efficiently walk the free lists whenever we need to go in and start
> > processing hints to the hypervisor that the pages are no longer in use.
> 
> You don't really walk them though, right?  It *keeps* you from having to
> ever walk the lists.

It all depends on your definition of "walk". In the case of this logic we
will have to ultimately do 1 pass over all the "raw" pages to process
them. So I consider that a walk through the free_list. However we can
avoid all of the already processed pages since we have the flag and the
pointer to what should be the top of the list for the "aerated" pages.

> I also don't see what the boundary has to do with aerated pages being on
> the tail of the list.  If you want them on the tail, you just always
> list_add_tail() them.

The issue is that there are multiple things that can add to the tail of
the list. For example the shuffle code or the lower order buddy expecting
its buddy to be freed. In those cases I don't want to add to tail so
instead I am adding those to the boundary. By doing that I can avoid
having the tail of the list becoming interleaved with raw and aerated
pages.

> > And added advantage to this approach is that we should be reducing the
> > overall memory footprint of the guest as it will be more likely to recycle
> > warm pages versus the aerated pages that are likely to be cache cold.
> 
> I'm confused.  Isn't an aerated page non-present on the guest?  That's
> worse than cache cold.  It costs a VMEXIT to bring back in.

I suppose so, it would be worse than being cache cold.

> > Since we will only be aerating one zone at a time we keep the boundary
> > limited to being defined for just the zone we are currently placing aerated
> > pages into. Doing this we can keep the number of additional poitners needed
> > quite small.
> 
> 							pointers ^
> 
> > +struct list_head *__aerator_get_tail(unsigned int order, int migratetype);
> >  static inline struct list_head *aerator_get_tail(struct zone *zone,
> >  						 unsigned int order,
> >  						 int migratetype)
> >  {
> > +#ifdef CONFIG_AERATION
> > +	if (order >= AERATOR_MIN_ORDER &&
> > +	    test_bit(ZONE_AERATION_ACTIVE, &zone->flags))
> > +		return __aerator_get_tail(order, migratetype);
> > +#endif
> >  	return &zone->free_area[order].free_list[migratetype];
> >  }
> 
> Logically, I have no idea what this is doing.  "Go get pages out of the
> aerated list?"  "raw list"?  Needs comments.

I'll add comments. Really now that I think about it I should probably
change the name for this anyway. What is really being returned is the tail
for the non-aerated list. Specifically if ZONE_AERATION_ACTIVE is set we
want to prevent any insertions below the list of aerated pages, so we are
returning the first entry in the aerated list and using that as the
tail/head of a list tail insertion.

Ugh. I really need to go back and name this better.

> > +static inline void aerator_del_from_boundary(struct page *page,
> > +					     struct zone *zone)
> > +{
> > +	if (PageAerated(page) && test_bit(ZONE_AERATION_ACTIVE, &zone->flags))
> > +		__aerator_del_from_boundary(page, zone);
> > +}
> > +
> >  static inline void set_page_aerated(struct page *page,
> >  				    struct zone *zone,
> >  				    unsigned int order,
> > @@ -28,6 +59,9 @@ static inline void set_page_aerated(struct page *page,
> >  	/* record migratetype and flag page as aerated */
> >  	set_pcppage_migratetype(page, migratetype);
> >  	__SetPageAerated(page);
> > +
> > +	/* update boundary of new migratetype and record it */
> > +	aerator_add_to_boundary(page, zone);
> >  #endif
> >  }
> >  
> > @@ -39,11 +73,19 @@ static inline void clear_page_aerated(struct page *page,
> >  	if (likely(!PageAerated(page)))
> >  		return;
> >  
> > +	/* push boundary back if we removed the upper boundary */
> > +	aerator_del_from_boundary(page, zone);
> > +
> >  	__ClearPageAerated(page);
> >  	area->nr_free_aerated--;
> >  #endif
> >  }
> >  
> > +static inline unsigned long aerator_raw_pages(struct free_area *area)
> > +{
> > +	return area->nr_free - area->nr_free_aerated;
> > +}
> > +
> >  /**
> >   * aerator_notify_free - Free page notification that will start page processing
> >   * @zone: Pointer to current zone of last page processed
> > @@ -57,5 +99,20 @@ static inline void clear_page_aerated(struct page *page,
> >   */
> >  static inline void aerator_notify_free(struct zone *zone, int order)
> >  {
> > +#ifdef CONFIG_AERATION
> > +	if (!static_key_false(&aerator_notify_enabled))
> > +		return;
> > +	if (order < AERATOR_MIN_ORDER)
> > +		return;
> > +	if (test_bit(ZONE_AERATION_REQUESTED, &zone->flags))
> > +		return;
> > +	if (aerator_raw_pages(&zone->free_area[order]) < AERATOR_HWM)
> > +		return;
> > +
> > +	__aerator_notify(zone);
> > +#endif
> >  }
> 
> Again, this is really hard to review.  I see some possible overhead in a
> fast path here, but only if aerator_notify_free() is called in a fast
> path.  Is it?  I have to go digging in the previous patches to figure
> that out.

This is called at the end of __free_one_page().

I tried to limit the impact as much as possible by ordering the checks the
way I did. The order check should limit the impact pretty significantly as
that is the only one that will be triggered for every page, then the
higher order pages are left to deal with the test_bit and
aerator_raw_pages checks.

> > +static struct aerator_dev_info *a_dev_info;
> > +struct static_key aerator_notify_enabled;
> > +
> > +struct list_head *boundary[MAX_ORDER - AERATOR_MIN_ORDER][MIGRATE_TYPES];
> > +
> > +static void aerator_reset_boundary(struct zone *zone, unsigned int order,
> > +				   unsigned int migratetype)
> > +{
> > +	boundary[order - AERATOR_MIN_ORDER][migratetype] =
> > +			&zone->free_area[order].free_list[migratetype];
> > +}
> > +
> > +#define for_each_aerate_migratetype_order(_order, _type) \
> > +	for (_order = MAX_ORDER; _order-- != AERATOR_MIN_ORDER;) \
> > +		for (_type = MIGRATE_TYPES; _type--;)
> > +
> > +static void aerator_populate_boundaries(struct zone *zone)
> > +{
> > +	unsigned int order, mt;
> > +
> > +	if (test_bit(ZONE_AERATION_ACTIVE, &zone->flags))
> > +		return;
> > +
> > +	for_each_aerate_migratetype_order(order, mt)
> > +		aerator_reset_boundary(zone, order, mt);
> > +
> > +	set_bit(ZONE_AERATION_ACTIVE, &zone->flags);
> > +}
> 
> This function appears misnamed as it's doing more than boundary
> manipulation.

The ZONE_AERATION_ACTIVE flag is what is used to indicate that the
boundaries are being tracked. Without that we just fall back to using the
free_list tail.

> > +struct list_head *__aerator_get_tail(unsigned int order, int migratetype)
> > +{
> > +	return boundary[order - AERATOR_MIN_ORDER][migratetype];
> > +}
> > +
> > +void __aerator_del_from_boundary(struct page *page, struct zone *zone)
> > +{
> > +	unsigned int order = page_private(page) - AERATOR_MIN_ORDER;
> > +	int mt = get_pcppage_migratetype(page);
> > +	struct list_head **tail = &boundary[order][mt];
> > +
> > +	if (*tail == &page->lru)
> > +		*tail = page->lru.next;
> > +}
> 
> Ewww.  Please just track the page that's the boundary, not the list head
> inside the page that's the boundary.
> 
> This also at least needs one comment along the lines of: Move the
> boundary if the page representing the boundary is being removed.

So the reason for using the list_head is because we can end up with a
boundary for an empty list. In that case we don't have a page to point to
but just the list_head for the list itself. It actually makes things quite
a bit simpler, otherwise I have to perform extra checks to see if the list
is empty.

I'll work on updating the comments.

> 
> > +void aerator_add_to_boundary(struct page *page, struct zone *zone)
> > +{
> > +	unsigned int order = page_private(page) - AERATOR_MIN_ORDER;
> > +	int mt = get_pcppage_migratetype(page);
> > +	struct list_head **tail = &boundary[order][mt];
> > +
> > +	*tail = &page->lru;
> > +}
> > +
> > +void aerator_shutdown(void)
> > +{
> > +	static_key_slow_dec(&aerator_notify_enabled);
> > +
> > +	while (atomic_read(&a_dev_info->refcnt))
> > +		msleep(20);
> 
> We generally frown on open-coded check/sleep loops.  What is this for?

We are waiting on the aerator to finish processing the list it had active.
With the static key disabled we should see the refcount wind down to 0.
Once that occurs we can safely free the a_dev_info structure since there
will be no other uses of it.

> > +	WARN_ON(!list_empty(&a_dev_info->batch));
> > +
> > +	a_dev_info = NULL;
> > +}
> > +EXPORT_SYMBOL_GPL(aerator_shutdown);
> > +
> > +static void aerator_schedule_initial_aeration(void)
> > +{
> > +	struct zone *zone;
> > +
> > +	for_each_populated_zone(zone) {
> > +		spin_lock(&zone->lock);
> > +		__aerator_notify(zone);
> > +		spin_unlock(&zone->lock);
> > +	}
> > +}
> 
> Why do we need an initial aeration?

This is mostly about avoiding any possible races while we are brining up
the aerator. If we assume we are just going to start a cycle of aeration
for all zones when the aerator is brought up it makes it easier to be sure
we have gone though and checked all of the zones after initialization is
complete.

> > +int aerator_startup(struct aerator_dev_info *sdev)
> > +{
> > +	if (a_dev_info)
> > +		return -EBUSY;
> > +
> > +	INIT_LIST_HEAD(&sdev->batch);
> > +	atomic_set(&sdev->refcnt, 0);
> > +
> > +	a_dev_info = sdev;
> > +	aerator_schedule_initial_aeration();
> > +
> > +	static_key_slow_inc(&aerator_notify_enabled);
> > +
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL_GPL(aerator_startup);
> > +
> > +static void aerator_fill(struct zone *zone)
> > +{
> > +	struct list_head *batch = &a_dev_info->batch;
> > +	int budget = a_dev_info->capacity;
> 
> Where does capacity come from?

It is the limit on how many pages we can process at a time. The value is
set in a_dev_info before the call to aerator_startup.

> > +	unsigned int order, mt;
> > +
> > +	for_each_aerate_migratetype_order(order, mt) {
> > +		struct page *page;
> > +
> > +		/*
> > +		 * Pull pages from free list until we have drained
> > +		 * it or we have filled the batch reactor.
> > +		 */
> 
> What's a reactor?

A hold-over from an earlier patch. Basically the batch reactor was the
list containing the pages to be processed. It was a chemistry term in
regards to aeration. I should update that to instead say we have reached
the capacity of the aeration device.

> > +		while ((page = get_aeration_page(zone, order, mt))) {
> > +			list_add_tail(&page->lru, batch);
> > +
> > +			if (!--budget)
> > +				return;
> > +		}
> > +	}
> > +
> > +	/*
> > +	 * If there are no longer enough free pages to fully populate
> > +	 * the aerator, then we can just shut it down for this zone.
> > +	 */
> > +	clear_bit(ZONE_AERATION_REQUESTED, &zone->flags);
> > +	atomic_dec(&a_dev_info->refcnt);
> > +}
> 
> Huh, so this is the number of threads doing aeration?  Didn't we just
> make a big deal about there only being one zone being aerated at a time?
>  Or, did I misunderstand what refcnt is from its lack of clear
> documentation?

The refcnt is the number of zones requesting aeration plus one additional
if the thread is active. We are limited to only having pages from one zone
in the aerator at a time. That is to prevent us from having to maintain
multiple boundaries.

> > +static void aerator_drain(struct zone *zone)
> > +{
> > +	struct list_head *list = &a_dev_info->batch;
> > +	struct page *page;
> > +
> > +	/*
> > +	 * Drain the now aerated pages back into their respective
> > +	 * free lists/areas.
> > +	 */
> > +	while ((page = list_first_entry_or_null(list, struct page, lru))) {
> > +		list_del(&page->lru);
> > +		put_aeration_page(zone, page);
> > +	}
> > +}
> > +
> > +static void aerator_scrub_zone(struct zone *zone)
> > +{
> > +	/* See if there are any pages to pull */
> > +	if (!test_bit(ZONE_AERATION_REQUESTED, &zone->flags))
> > +		return;
> 
> How would someone ask for the zone to be scrubbed when aeration has not
> been requested?

I'm not sure what you are asking here. Basically this function is called
per zone by aerator_cycle. Which now that I think about it I should
probably swap the names around that we perform a cycle per zone and just
scrub memory generically.

> > +	spin_lock(&zone->lock);
> > +
> > +	do {
> > +		aerator_fill(zone);
> 
> Should this say:
> 
> 		/* Pull pages out of the allocator into a local list */
> 
> ?

Yes, we are filling the local list with "raw" pages from the zone.

> 
> > +		if (list_empty(&a_dev_info->batch))
> > +			break;
> 
> 		/* no pages were acquired, give up */

Correct.

> 
> > +		spin_unlock(&zone->lock);
> > +
> > +		/*
> > +		 * Start aerating the pages in the batch, and then
> > +		 * once that is completed we can drain the reactor
> > +		 * and refill the reactor, restarting the cycle.
> > +		 */
> > +		a_dev_info->react(a_dev_info);
> 
> After reading (most of) this set, I'm going to reiterate my suggestion:
> please find new nomenclature.  I can't parse that comment and I don't
> know whether that's because it's a bad comment or whether you really
> mean "cycle" the english word or "cycle" referring to some new
> definition relating to this patch set.
> 
> I've asked quite nicely a few times now.

The "cycle" in this case refers to fill, react, drain, and idle or repeat.

> > +		spin_lock(&zone->lock);
> > +
> > +		/*
> > +		 * Guarantee boundaries are populated before we
> > +		 * start placing aerated pages in the zone.
> > +		 */
> > +		aerator_populate_boundaries(zone);
> 
> aerator_populate_boundaries() has apparent concurrency checks via
> ZONE_AERATION_ACTIVE.  Why are those needed when this is called under a
> spinlock?

I probably could move the spin_lock down. It isn't really needed for the
population of the boundaries, it was needed for the draining of the
aerator into the free_lists.  I'll move the lock, although I might need to
add a smp_mb__before_atomic to make sure that any callers see the boundary
values before they see the updated bit.

