Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD91DC10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 15:41:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A0812147A
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 15:41:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A0812147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 293826B0003; Mon,  8 Apr 2019 11:41:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 269316B000C; Mon,  8 Apr 2019 11:41:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12FCF6B000D; Mon,  8 Apr 2019 11:41:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2BBC6B0003
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 11:41:41 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z34so13087690qtz.14
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 08:41:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=KbSK/X7JpCK8bNGWrUsaZVBhOGOX0n/BBtcnFxS/8fs=;
        b=OaCZh0nIaMkq/+cC+S6iDFmM1NpeaVWJ7HP1/29vUT0vpOuqA31Mndznj4f8pSuLbH
         63V6r/li6nxEbkTF/vyUPW98tV025wzEZFYjPH5SgTTrm6hvFixhsaBs9X9ZlkIAlP9Z
         ZZSi5FXMQceD8sp7dlN0xFDTW+vRTkkpwohGN0lOaxUYYxqgZxHdq+Y2aIP2o5nIzque
         IOA1ziAWoOqpAcWVuW1jps6J3sFn3urXIn+TAl/mFX14/AnNraXtrFQHKAYABeRgKs/Q
         9P6L53qIXvPLJ4ur2G2xPhm+N6CiqG3zdn9OHPTe6JM2nhuBz4a8V2fuPb9ec2k0a2vx
         ctNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVrdRyW7eHH4YV86jrN2h5QW/RmFG3JajMeI2l5hP6SEU2Iszp8
	lCnzymWT3Z3Btq++tf8704B0vTfoRnFXboHWYz1o+3gByQxW2LGXiPbeMpUi8uxuoCPzJu3sHC3
	Bm4oxN2WCQtHIF51iSYgYsEw+48qRQfoPnp4/QGP7IceXZH2GOlLqcNiMwRye8VM9SQ==
X-Received: by 2002:ac8:1a6d:: with SMTP id q42mr24351879qtk.129.1554738101690;
        Mon, 08 Apr 2019 08:41:41 -0700 (PDT)
X-Received: by 2002:ac8:1a6d:: with SMTP id q42mr24351809qtk.129.1554738100829;
        Mon, 08 Apr 2019 08:41:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554738100; cv=none;
        d=google.com; s=arc-20160816;
        b=sRUlWZLFSEk1xgG0j0VIUAol9IkVPYjLT5I065xQL9WU2X4egm7Ul1/JQmtYZseVl/
         p5PkPiNip7kDIC6KJ9jJqpsLYIDc6+YCU35xWAxjAePaaIwsL7RYQZ65810W9bGmw16u
         p5L9ezc0EqxpEi2kUpG+2BvwvTfk03jljBxs5WSbvvqZ4C9SbcX4EAhcJ0qwNVdqAIVu
         vGpWG0wc1rgGF4+ebpeyCPY8U7JDllzmZvtd2rZIcpOJzqEXn3SSSymlGwSVuzfwLvrl
         DqMFWVxP9UMuIlCqRjlBWgqEbMa3FA8FX5Jyrdmae4/abYflZv3XT/ej+GLfmqloMeUp
         d4iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=KbSK/X7JpCK8bNGWrUsaZVBhOGOX0n/BBtcnFxS/8fs=;
        b=Xgo/G4is7l8L2RLbcS+EyUw+39OHKFuaeIYXrTEzCUasGKobvqgrKM/kIdbXeIHyev
         2CEEzYKsX+SabMMYSHeOyiMmcLz8dvEOI+ndtlOt2cIGfVB/etDI4kttT6DU7rGpgs1+
         9v5U8mM99oI+zZs7iQNQ5wlrg9gdS7jR/SfxpqTZjqZfiECI4JqETTQsIxIeJAFRgvXa
         sTJRPb0SH/Nn4Heo2iBMZRk7J44n1FiLZPInvdXfuE/C8DivFirjj8iH9gUjWjGgXh0n
         T3j+65WouRdltmNq51oDWbWvHGb52ZI4o20WBPbRSZx5hrEx5XAx0JvTQGcHCbBC9mD+
         pAvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4sor17303569qki.39.2019.04.08.08.41.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 08:41:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyR+Tmybn5PEyV/U1anHtWHt8mzskoJUOa0HgzEm9nr8z+jOm6rM1uak2YaEiN2laszY0bl6Q==
X-Received: by 2002:a05:620a:1472:: with SMTP id j18mr23201976qkl.63.1554738100329;
        Mon, 08 Apr 2019 08:41:40 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id n41sm20262796qtf.63.2019.04.08.08.41.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 08 Apr 2019 08:41:39 -0700 (PDT)
Date: Mon, 8 Apr 2019 11:41:35 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>,
	David Hildenbrand <david@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Thoughts on simple scanner approach for free page hinting
Message-ID: <20190408114052-mutt-send-email-mst@kernel.org>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <ef0c542a-ded5-f063-e6e2-8e84d1c12c85@redhat.com>
 <CAKgT0UfyG=0wg5jzZPcnh7Q1rf0+gd9H5Q4626GTft85EiJNeA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UfyG=0wg5jzZPcnh7Q1rf0+gd9H5Q4626GTft85EiJNeA@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 08, 2019 at 08:18:35AM -0700, Alexander Duyck wrote:
> On Mon, Apr 8, 2019 at 5:24 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >
> >
> > On 4/5/19 8:09 PM, Alexander Duyck wrote:
> > > So I am starting this thread as a spot to collect my thoughts on the
> > > current guest free page hinting design as well as point out a few
> > > possible things we could do to improve upon it.
> > >
> > > 1. The current design isn't likely going to scale well to multiple
> > > VCPUs. The issue specifically is that the zone lock must be held to
> > > pull pages off of the free list and to place them back there once they
> > > have been hinted upon. As a result it would likely make sense to try
> > > to limit ourselves to only having one thread performing the actual
> > > hinting so that we can avoid running into issues with lock contention
> > > between threads.
> > >
> > > 2. There are currently concerns about the hinting triggering false OOM
> > > situations if too much memory is isolated while it is being hinted. My
> > > thought on this is to simply avoid the issue by only hint on a limited
> > > amount of memory at a time. Something like 64MB should be a workable
> > > limit without introducing much in the way of regressions. However as a
> > > result of this we can easily be overrun while waiting on the host to
> > > process the hinting request. As such we will probably need a way to
> > > walk the free list and free pages after they have been freed instead
> > > of trying to do it as they are freed.
> > >
> > > 3. Even with the current buffering which is still on the larger side
> > > it is possible to overrun the hinting limits if something causes the
> > > host to stall and a large swath of memory is released. As such we are
> > > still going to need some sort of scanning mechanism or will have to
> > > live with not providing accurate hints.
> > >
> > > 4. In my opinion, the code overall is likely more complex then it
> > > needs to be. We currently have 2 allocations that have to occur every
> > > time we provide a hint all the way to the host, ideally we should not
> > > need to allocate more memory to provide hints. We should be able to
> > > hold the memory use for a memory hint device constant and simply map
> > > the page address and size to the descriptors of the virtio-ring.
> > >
> > > With that said I have a few ideas that may help to address the 4
> > > issues called out above. The basic idea is simple. We use a high water
> > > mark based on zone->free_area[order].nr_free to determine when to wake
> > > up a thread to start hinting memory out of a given free area. From
> > > there we allocate non-"Offline" pages from the free area and assign
> > > them to the hinting queue up to 64MB at a time. Once the hinting is
> > > completed we mark them "Offline" and add them to the tail of the
> > > free_area. Doing this we should cycle the non-"Offline" pages slowly
> > > out of the free_area.
> > any ideas about how are you planning to control this?

I think supplying the 64M value from host is probably reasonable.

> 
> You mean in terms of switching the hinting on/off? The setup should be
> pretty simple. Basically we would still need a hook like the one you
> added after the allocation to determine where the free page ultimately
> landed and to do a check against the high water mark I mentioned.
> Basically if there is something like 2X the number of pages needed to
> fulfill the 64MB requirement we could then kick off a thread running
> on the zone to begin populating the hints and notifying the
> virtio-balloon interface. When we can no longer fill the ring we would
> simply stop the thread until we get back to the 2X state for nr_freed
> versus the last nr_freed value we had hinted upon. It wouldn't be
> dissimilar to how we currently handle the Tx path in many NICs where
> we shut off hinting.
> 
> For examples of doing something like this you could look at the Rx
> softIRQ handling in the NIC drivers. Basically the idea there is you
> trigger the event once, and then the thread is running until all work
> has been completed. The thread itself is limiting itself to only
> processing some number of fixed buffers for each request, and when it
> can no longer get a full set it stops and waits to be rescheduled by
> an interrupt.
> 
> > > In addition the search cost should be minimal
> > > since all of the "Offline" pages should be aggregated to the tail of
> > > the free_area so all pages allocated off of the free_area will be the
> > > non-"Offline" pages until we shift over to them all being "Offline".
> > > This should be effective for MAX_ORDER - 1 and MAX_ORDER - 2 pages
> > > since the only real consumer of add_to_free_area_tail is
> > > __free_one_page which uses it to place a page with an order less than
> > > MAX_ORDER - 2 on the tail of a free_area assuming that it should be
> > > freeing the buddy of that page shortly. The only other issue with
> > > adding to tail would be the memory shuffling which was recently added,
> > > but I don't see that as being something that will be enabled in most
> > > cases so we could probably just make the features mutually exclusive,
> > > at least for now.
> > >
> > > So if I am not mistaken this would essentially require a couple
> > > changes to the mm infrastructure in order for this to work.
> > >
> > > First we would need to split nr_free into two counters, something like
> > > nr_freed and nr_bound. You could use nr_freed - nr_bound to get the
> > > value currently used for nr_free. When we pulled the pages for hinting
> > > we would reduce the nr_freed value and then add back to it when the
> > > pages are returned. When pages are allocated they would increment the
> > > nr_bound value. The idea behind this is that we can record nr_free
> > > when we collect the pages and save it to some local value. This value
> > > could then tell us how many new pages have been added that have not
> > > been hinted upon.
> > >
> > > In addition we will need some way to identify which pages have been
> > > hinted on and which have not. The way I believe easiest to do this
> > > would be to overload the PageType value so that we could essentially
> > > have two values for "Buddy" pages. We would have our standard "Buddy"
> > > pages, and "Buddy" pages that also have the "Offline" value set in the
> > > PageType field. Tracking the Online vs Offline pages this way would
> > > actually allow us to do this with almost no overhead as the mapcount
> > > value is already being reset to clear the "Buddy" flag so adding a
> > > "Offline" flag to this clearing should come at no additional cost.
> > >
> > > Lastly we would need to create a specialized function for allocating
> > > the non-"Offline" pages, and to tweak __free_one_page to tail enqueue
> > > "Offline" pages. I'm thinking the alloc function it would look
> > > something like __rmqueue_smallest but without the "expand" and needing
> > > to modify the !page check to also include a check to verify the page
> > > is not "Offline". As far as the changes to __free_one_page it would be
> > > a 2 line change to test for the PageType being offline, and if it is
> > > to call add_to_free_area_tail instead of add_to_free_area.
> > Is it possible that once the pages are offline, there is a large
> > allocation request in the guest needing those offline pages as well?
> 
> It is possible. However the behavior here would be no different from a
> NIC driver. NIC drivers will sit on a swath of memory for Rx purposes
> waiting for the DMA to occur. Here we are sitting on 64MB which for a
> large allocation should not be that significant.
> 
> As far as avoiding it, I don't think there is any way we can avoid
> such an event completely. There are scenerios where the hitning will
> get hung up while sitting on memory for an extended period of time.
> That is why I am thinking our best mitigation for now would be to keep
> the amount of hinting we are doing confined to something on the
> smaller side such as 64M or less which I have already mentioned. By
> doing that if we do hit one of the problematic scenarios we should
> have minimal impact.
> 
> > >
> > > Anyway this email ended up being pretty massive by the time I was
> > > done. Feel free to reply to parts of it and we can break it out into
> > > separate threads of discussion as necessary. I will start working on
> > > coding some parts of this next week.
> > >
> > > Thanks.
> > >
> > > - Alex
> > --
> > Regards
> > Nitesh
> >

