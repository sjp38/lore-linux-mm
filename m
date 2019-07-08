Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D5BAC606D3
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 22:02:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4540216FD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 22:02:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4540216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 322C48E0036; Mon,  8 Jul 2019 18:02:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AC838E0032; Mon,  8 Jul 2019 18:02:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14E488E0036; Mon,  8 Jul 2019 18:02:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA07C8E0032
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 18:02:50 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i2so11125833pfe.1
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 15:02:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=IIbhKHmA3MuhPivBZr6Cj2JQ8cR1nz+s7mV43F1HthE=;
        b=qkOd5E91sV4EOk1vJUOLGVWHaZWL0B1F/cn+eKysWiPEhCmUl8jpjngEuDVbVBndoe
         mVmZ0oCIHHoui1hU7S199yX7wBSuSxWT14/6i7C2ABq/DeTtlAEJID1T3p0RG33O9Ht+
         2T79yVpgBMN3A5PaeSv2jHW117oxkruKqfsXivD8mzU39Z0DtN7UNqfYfohmZ77q3BQl
         xK0M5n4gewRUWWiU1myAlr81Cay3t3HagpYd9nyvS7UiX/aWdWcMwORUUlR6n1st9uIn
         HZXtpvXtWH6a3GgF5XoXpQOTjWDxgKi4eim5VqZHrSs6PcZ9g3T3T3EbvQy//TosRUNR
         4cQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWNmIvRAAvt61RaCDsXnc4PeoDMI1l2DRoIecircejXFp03u466
	rTaYP+zOqCKn1A4cWcVaQtJyqdrrnELcB4eyHjuHW9GrVrrDQGFSabwbmZo9iDmHrgPV+tPI2mQ
	9jPd2SGZewTzn+E70G1rZW6o2JSJuNUqFgcbQ4HJGF0ToPsIb1cUSzMPLCvDysHHpoA==
X-Received: by 2002:a17:90a:19d:: with SMTP id 29mr28889015pjc.71.1562623370336;
        Mon, 08 Jul 2019 15:02:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3EuVnmQLrAx+Ff4p6WJI6jCbhHFB9ECE+B4txSBgRuMn7OeNN9I4WpcjY989xcvZj3sTD
X-Received: by 2002:a17:90a:19d:: with SMTP id 29mr28888862pjc.71.1562623368567;
        Mon, 08 Jul 2019 15:02:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562623368; cv=none;
        d=google.com; s=arc-20160816;
        b=uaA/wiYVl/z/ZlBJ1r3hDrMQSy73mFy6R7ArHdlFrd8Ls4TBmd1BjT0TCpj9mF5ZtW
         mDO9vH69YhMSblMeByxiAcKhBPZHz0TW9otu4HLZFkdNLIxPL+A/TWsyoIpNNKbdMnnA
         3zVik3rm5c20utudxWfXBkkWEHOQ2YNK4DpPNxjcYdSY0UTfjaiKTUNGjw3FraCoVEqF
         JITzojk1+4Zu/EQvPJiYCVGcBltY7me4dfYyTeB0Ony0C3p9Og5ptC72eF2ChfxoqRTB
         EGNbeChePYBTqY/bcdWdKequ2DFZlO2rAp4THU0W5RCm1gM35labkcN7o2pyJrCdZjuP
         4OvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=IIbhKHmA3MuhPivBZr6Cj2JQ8cR1nz+s7mV43F1HthE=;
        b=Mr7GVduG2qhMdi2ppSWPqHhsfDaF9DoJASSj8gKMuZhaBqA/wBmq/+wEdRD7SO57eY
         MDR3Bm4mE2jSAwUO6oQ0q57pk2YBzxJfNIOOTAmtrhL3DZqaDLRFShp0DL2kzYkTqZzc
         5PPhTLhhCmZysTzSXxxdPgKzKpKVJBU+GscA2U8QSWvmPF3v1RxH595L5m6PIe5zsTXu
         MPPAvCcYrfUhSzBnvd62LPzau5D8Q/EjcS07V2c/TR95UX3m9SxU+znJ3MS4QatbAck/
         miC2itdPm0T2NadOT2Z/OVZ/RoOo90mSX9jMZGT7zalDKH80ngLEKZMGikmJIM7vx0oc
         MFUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id cn1si20440807plb.204.2019.07.08.15.02.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 15:02:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Jul 2019 15:02:46 -0700
X-IronPort-AV: E=Sophos;i="5.63,468,1557212400"; 
   d="scan'208";a="167796859"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga003-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Jul 2019 15:02:45 -0700
Message-ID: <75a2e62975ef440e231304ddbf4f8deb51ee1fd4.camel@linux.intel.com>
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
Date: Mon, 08 Jul 2019 15:02:45 -0700
In-Reply-To: <a73eac6b-7fce-7a0d-46ab-1a7aa10dfe08@intel.com>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
	 <20190619223331.1231.39271.stgit@localhost.localdomain>
	 <f704f160-49fb-2fdf-e8ac-44b47245a75c@intel.com>
	 <66a43ec2912265ff7f1a16e0cf5258d5c3c61de5.camel@linux.intel.com>
	 <a73eac6b-7fce-7a0d-46ab-1a7aa10dfe08@intel.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-07-08 at 12:36 -0700, Dave Hansen wrote:
> On 7/8/19 12:02 PM, Alexander Duyck wrote:
> > On Tue, 2019-06-25 at 13:24 -0700, Dave Hansen wrote:
> > > I also don't see what the boundary has to do with aerated pages being on
> > > the tail of the list.  If you want them on the tail, you just always
> > > list_add_tail() them.
> > 
> > The issue is that there are multiple things that can add to the tail of
> > the list. For example the shuffle code or the lower order buddy expecting
> > its buddy to be freed. In those cases I don't want to add to tail so
> > instead I am adding those to the boundary. By doing that I can avoid
> > having the tail of the list becoming interleaved with raw and aerated
> > pages.
> 
> So, it sounds like we've got the following data structure rules:
> 
> 1. We have one list_head and one list of pages
> 2. For the purposes of allocation, the list is treated the same as
>    before these patches

So these 2 points are correct.

> 3. For a "free()", the behavior changes and we now have two "tails":
>    3a. Aerated pages are freed into the tail of the list
>    3b. Cold pages are freed at the boundary between aerated and non.
>        This serves to...  This is also referred to as a "tail".
>    3a. Hot pages are never aerated and are still freed into the head
>        of the list.
> 
> Did I miss any?  Could you please spell it out this way in future
> changelogs?

So the logic for 3a and 3b is actually the same location. The difference
is that the boundary pointer will move up to the page in the case of 3a,
and will not move in the case of 3b. That was why I was kind of annoyed
with myself as I was calling it the aerator "tail" when it is really the
head of the aeration list.

So the change I am planning to make in terms of naming is to refer to
__aerator_get_boundary in the function below. Boundary makes more sense in
my mind anyway because it is the head of one list and the tail of the
other.

> 
> > > > +struct list_head *__aerator_get_tail(unsigned int order, int migratetype);
> > > >  static inline struct list_head *aerator_get_tail(struct zone *zone,
> > > >  						 unsigned int order,
> > > >  						 int migratetype)
> > > >  {
> > > > +#ifdef CONFIG_AERATION
> > > > +	if (order >= AERATOR_MIN_ORDER &&
> > > > +	    test_bit(ZONE_AERATION_ACTIVE, &zone->flags))
> > > > +		return __aerator_get_tail(order, migratetype);
> > > > +#endif
> > > >  	return &zone->free_area[order].free_list[migratetype];
> > > >  }
> > > 
> > > Logically, I have no idea what this is doing.  "Go get pages out of the
> > > aerated list?"  "raw list"?  Needs comments.
> > 
> > I'll add comments. Really now that I think about it I should probably
> > change the name for this anyway. What is really being returned is the tail
> > for the non-aerated list. Specifically if ZONE_AERATION_ACTIVE is set we
> > want to prevent any insertions below the list of aerated pages, so we are
> > returning the first entry in the aerated list and using that as the
> > tail/head of a list tail insertion.
> > 
> > Ugh. I really need to go back and name this better.
> 
> OK, so we now have two tails?  One that's called both a boundary and a
> tail at different parts of the code?

Yes, that is the naming issue I was getting at. I would prefer to go with
boundary where I can since it is both a head of one list and the tail of
the other.

I will try to clean this all up before I submit this again.

> > > >  static inline void aerator_notify_free(struct zone *zone, int order)
> > > >  {
> > > > +#ifdef CONFIG_AERATION
> > > > +	if (!static_key_false(&aerator_notify_enabled))
> > > > +		return;
> > > > +	if (order < AERATOR_MIN_ORDER)
> > > > +		return;
> > > > +	if (test_bit(ZONE_AERATION_REQUESTED, &zone->flags))
> > > > +		return;
> > > > +	if (aerator_raw_pages(&zone->free_area[order]) < AERATOR_HWM)
> > > > +		return;
> > > > +
> > > > +	__aerator_notify(zone);
> > > > +#endif
> > > >  }
> > > 
> > > Again, this is really hard to review.  I see some possible overhead in a
> > > fast path here, but only if aerator_notify_free() is called in a fast
> > > path.  Is it?  I have to go digging in the previous patches to figure
> > > that out.
> > 
> > This is called at the end of __free_one_page().
> > 
> > I tried to limit the impact as much as possible by ordering the checks the
> > way I did. The order check should limit the impact pretty significantly as
> > that is the only one that will be triggered for every page, then the
> > higher order pages are left to deal with the test_bit and
> > aerator_raw_pages checks.
> 
> That sounds like a good idea.  But, that good idea is very hard to
> distill from the code in the patch.
> 
> Imagine if the function stared being commented with:
> 
> /* Called from a hot path in __free_one_page() */
> 
> And said:
> 
> 
> 	if (!static_key_false(&aerator_notify_enabled))
> 		return;
> 
> 	/* Avoid (slow) notifications when no aeration is performed: */
> 	if (order < AERATOR_MIN_ORDER)
> 		return;
> 	if (test_bit(ZONE_AERATION_REQUESTED, &zone->flags))
> 		return;
> 
> 	/* Some other relevant comment: */
> 	if (aerator_raw_pages(&zone->free_area[order]) < AERATOR_HWM)
> 		return;
> 
> 	/* This is slow, but should happen very rarely: */
> 	__aerator_notify(zone);
> 

I'll go through and work on cleaning up the comments.

> > > > +static void aerator_populate_boundaries(struct zone *zone)
> > > > +{
> > > > +	unsigned int order, mt;
> > > > +
> > > > +	if (test_bit(ZONE_AERATION_ACTIVE, &zone->flags))
> > > > +		return;
> > > > +
> > > > +	for_each_aerate_migratetype_order(order, mt)
> > > > +		aerator_reset_boundary(zone, order, mt);
> > > > +
> > > > +	set_bit(ZONE_AERATION_ACTIVE, &zone->flags);
> > > > +}
> > > 
> > > This function appears misnamed as it's doing more than boundary
> > > manipulation.
> > 
> > The ZONE_AERATION_ACTIVE flag is what is used to indicate that the
> > boundaries are being tracked. Without that we just fall back to using the
> > free_list tail.
> 
> Is the flag used for other things?  Or just to indicate that boundaries
> are being tracked?

Just the boundaries. It gets set before the first time we have to flush
out a batch of pages, and is cleared after we have determined that there
are no longer any pages to pull and our local list is empty.

> > > > +struct list_head *__aerator_get_tail(unsigned int order, int migratetype)
> > > > +{
> > > > +	return boundary[order - AERATOR_MIN_ORDER][migratetype];
> > > > +}
> > > > +
> > > > +void __aerator_del_from_boundary(struct page *page, struct zone *zone)
> > > > +{
> > > > +	unsigned int order = page_private(page) - AERATOR_MIN_ORDER;
> > > > +	int mt = get_pcppage_migratetype(page);
> > > > +	struct list_head **tail = &boundary[order][mt];
> > > > +
> > > > +	if (*tail == &page->lru)
> > > > +		*tail = page->lru.next;
> > > > +}
> > > 
> > > Ewww.  Please just track the page that's the boundary, not the list head
> > > inside the page that's the boundary.
> > > 
> > > This also at least needs one comment along the lines of: Move the
> > > boundary if the page representing the boundary is being removed.
> > 
> > So the reason for using the list_head is because we can end up with a
> > boundary for an empty list. In that case we don't have a page to point to
> > but just the list_head for the list itself. It actually makes things quite
> > a bit simpler, otherwise I have to perform extra checks to see if the list
> > is empty.
> 
> Could you please double-check that keeping a 'struct page *' is truly
> more messy?

Well there are a few places I am using this where using a page pointer
would be an issue.

1. add_to_free_area_tail
      Using a page pointer here would be difficult since we are adding a
      page to a list, not to another page.
2. aerator_populate_boundaries
      We were initializing the boundary to the list head for each of the
      free_lists that we could possibly be placing pages into. Translating
      to a page would require additional overhead.
3. __aerator_del_from_boundary
      What we can end up with here if we aren't careful is a page pointer
      that isn't to a page in the case that the free_list is actually
      empty.

In my mind in order to handle this correctly I would have to start using
NULL when the list is empty, and have to add a check to
__aerator_del_from_boundary that would go in and grab the free_list for
the page and test against the head of the free list to make certain that
removing the page will not cause us to point to something that isn't a
page.


> > > > +void aerator_add_to_boundary(struct page *page, struct zone *zone)
> > > > +{
> > > > +	unsigned int order = page_private(page) - AERATOR_MIN_ORDER;
> > > > +	int mt = get_pcppage_migratetype(page);
> > > > +	struct list_head **tail = &boundary[order][mt];
> > > > +
> > > > +	*tail = &page->lru;
> > > > +}
> > > > +
> > > > +void aerator_shutdown(void)
> > > > +{
> > > > +	static_key_slow_dec(&aerator_notify_enabled);
> > > > +
> > > > +	while (atomic_read(&a_dev_info->refcnt))
> > > > +		msleep(20);
> > > 
> > > We generally frown on open-coded check/sleep loops.  What is this for?
> > 
> > We are waiting on the aerator to finish processing the list it had active.
> > With the static key disabled we should see the refcount wind down to 0.
> > Once that occurs we can safely free the a_dev_info structure since there
> > will be no other uses of it.
> 
> That's fine, but we still don't open-code sleep loops.  Please remove this.
> 
> "Wait until we can free the thing" sounds to me like RCU.  Do you want
> to use RCU here?  A synchronize_rcu() call can be a very powerful thing
> if the read-side critical sections are amenable to it.

So the issue is I am not entirely sure RCU would be a good fit here. Now I
could handle the __aerator_notify call via an RCU setup, however the call
to aerator_cycle probably wouldn't work well with it since it would be
holding onto a_dev_info for an extended period of time and we wouldn't
want to stall RCU out because the system is busy aerating a big section of
memory.

I'll have to think about this some more. As it currently stands I don't
think this completely solves what it is meant to anyway since I think it
is possible to race and end up with a scenario where another CPU might be
able to get past the static key check before we disable it, and then we
could free a_dev_info before it has a chance to take a reference to it.

> > > > +static void aerator_schedule_initial_aeration(void)
> > > > +{
> > > > +	struct zone *zone;
> > > > +
> > > > +	for_each_populated_zone(zone) {
> > > > +		spin_lock(&zone->lock);
> > > > +		__aerator_notify(zone);
> > > > +		spin_unlock(&zone->lock);
> > > > +	}
> > > > +}
> > > 
> > > Why do we need an initial aeration?
> > 
> > This is mostly about avoiding any possible races while we are brining up
> > the aerator. If we assume we are just going to start a cycle of aeration
> > for all zones when the aerator is brought up it makes it easier to be sure
> > we have gone though and checked all of the zones after initialization is
> > complete.
> 
> Let me ask a different way:  What will happen if we don't have this?
> Will things crash?  Will they be slow?  Do we not know?

I wouldn't expect any crashes. We may just not end up with the memory
being freed for some time if all the pages are freed before the aerator
device is registered, and there isn't any memory activity after that.

This was mostly about just making sure we flush the memory after the
device has been initialized.

> > > > +{
> > > > +	struct list_head *batch = &a_dev_info->batch;
> > > > +	int budget = a_dev_info->capacity;
> > > 
> > > Where does capacity come from?
> > 
> > It is the limit on how many pages we can process at a time. The value is
> > set in a_dev_info before the call to aerator_startup.
> 
> Let me ask another way: Does it come from the user?  Or is it
> automatically determined by some in-kernel heuristic?

It is being provided by the module that registers the aeration device. So
in patch 6 of the series we determined that we wanted to process 32 pages
at a time. So we set that as the limit since that is the number of hints
we had allocated in the virtio-balloon driver.

> > > > +		while ((page = get_aeration_page(zone, order, mt))) {
> > > > +			list_add_tail(&page->lru, batch);
> > > > +
> > > > +			if (!--budget)
> > > > +				return;
> > > > +		}
> > > > +	}
> > > > +
> > > > +	/*
> > > > +	 * If there are no longer enough free pages to fully populate
> > > > +	 * the aerator, then we can just shut it down for this zone.
> > > > +	 */
> > > > +	clear_bit(ZONE_AERATION_REQUESTED, &zone->flags);
> > > > +	atomic_dec(&a_dev_info->refcnt);
> > > > +}
> > > 
> > > Huh, so this is the number of threads doing aeration?  Didn't we just
> > > make a big deal about there only being one zone being aerated at a time?
> > >  Or, did I misunderstand what refcnt is from its lack of clear
> > > documentation?
> > 
> > The refcnt is the number of zones requesting aeration plus one additional
> > if the thread is active. We are limited to only having pages from one zone
> > in the aerator at a time. That is to prevent us from having to maintain
> > multiple boundaries.
> 
> That sounds like excellent documentation to add to 'refcnt's definition.

Will do.

> > > > +static void aerator_drain(struct zone *zone)
> > > > +{
> > > > +	struct list_head *list = &a_dev_info->batch;
> > > > +	struct page *page;
> > > > +
> > > > +	/*
> > > > +	 * Drain the now aerated pages back into their respective
> > > > +	 * free lists/areas.
> > > > +	 */
> > > > +	while ((page = list_first_entry_or_null(list, struct page, lru))) {
> > > > +		list_del(&page->lru);
> > > > +		put_aeration_page(zone, page);
> > > > +	}
> > > > +}
> > > > +
> > > > +static void aerator_scrub_zone(struct zone *zone)
> > > > +{
> > > > +	/* See if there are any pages to pull */
> > > > +	if (!test_bit(ZONE_AERATION_REQUESTED, &zone->flags))
> > > > +		return;
> > > 
> > > How would someone ask for the zone to be scrubbed when aeration has not
> > > been requested?
> > 
> > I'm not sure what you are asking here. Basically this function is called
> > per zone by aerator_cycle. Which now that I think about it I should
> > probably swap the names around that we perform a cycle per zone and just
> > scrub memory generically.
> 
> It looks like aerator_cycle() calls aerator_scrub_zone() on all zones
> all the time.  This is the code responsible for ensuring that we don't
> do any aeration work on zones that do not need it.

Yes, that is correct.

Based on your comment here and a few other spots I am assuming you would
prefer to see these sort of tests pulled out and done before we call the
function? I'm assuming that was the case after I started to see the
pattern so I will update that for the next patch set.


