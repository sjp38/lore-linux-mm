Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12E40C10F14
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:29:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0E2020830
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:29:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oDW0TM5d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0E2020830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 522A56B0275; Mon,  8 Apr 2019 14:29:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D1D16B0276; Mon,  8 Apr 2019 14:29:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E9376B0277; Mon,  8 Apr 2019 14:29:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA186B0275
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 14:29:30 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id z6so11872809ioh.16
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 11:29:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hsELHUWfDrJGX9dc+Y4VaPIgthl5gTtW1e2RiuINGDI=;
        b=IZYzS7Wnnd2hVriJn1ZZE6JKVZVkPBRCl3e/32A553NPnEEiu37v+fPvZHvGKVNSwF
         1TCEcoIyZglmF+C7XWG95b9mAarzxLxDrDNCDqJiubXDYmcEO+Y2l9wb19ELnTAsAgVT
         VI44XGn6IIjtbXwVBUiOmO+yLxgx4PiujE87iMWBb8euiQf+r28QKWfhJ4r+Nf09652u
         mXDOPeBRZB3K0UfgmSnQIvkOU+a65hXwpS1usxrAQhpHNBl444dpJ5u0qr+aZCjJoMRd
         ElWVqQbkMecX7J391NDvY42UpCYEPUCYS/VX4mAsnPR4ruUfgR83+XMk3FMaO1ov9Sz2
         KaGA==
X-Gm-Message-State: APjAAAU3RxDdJSl8qyPAh/UQJrdCjCZhPgCw9N2fEInp9VEPNZheKSK/
	JSaiEjiA7ZJVkiU9bK9n0+sfpa+BRBcXoKsgd5MasHuwGdVyOYoJy7ErzOnMTFZ5Lh7q57eyV0+
	pAOtzKIh+Uxy6z5XbTS0SybmlRBWrcF/kLwcAzLfOYO1DeN9YVu/PPt73nYl5uyJY/Q==
X-Received: by 2002:a24:454e:: with SMTP id y75mr21382164ita.5.1554748169811;
        Mon, 08 Apr 2019 11:29:29 -0700 (PDT)
X-Received: by 2002:a24:454e:: with SMTP id y75mr21382098ita.5.1554748168680;
        Mon, 08 Apr 2019 11:29:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554748168; cv=none;
        d=google.com; s=arc-20160816;
        b=ZcDzuXSpyiS4vEkTmP/BN9wrBxPgtjZBNBFiTNAhyi1MRhhrnrUdf36f4Gl50CJaBM
         +cUeuRHYyhEkBHlurOvVf+ePcDJEhCXvIBp0xyjhEj1CZB9lzrr+6Ch5vlZ1sRgJoVx1
         SZ7QeyXo0ZhI/Thfs4Ogruwy+Bi8qEZgX/hIQJ0Pg8QdWsGZ/qNQooaFeG449IPZarcL
         gVDCWh1i9p4B4IT2tSUozr1zZddH0/No8Lbw1zaJTLQJWfy6x5CpPNpAXl6ozz9bHgj+
         FddbC8o4qnQ1RDndPyeW+wivNA5gauhi3pzvkQkKlJ/ts7d7j/28VPnUhgmPPvA0lbiF
         Ydig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hsELHUWfDrJGX9dc+Y4VaPIgthl5gTtW1e2RiuINGDI=;
        b=nn1jf81qIfxmMBi7pUvQ/uMCtpX9So1nEWBYdDZTpAAjqqIWhVJqQTOF5YYk9WSD5D
         j4kBfewefw4bb8lziPLdJMimlnk4sj/EKZXJZbbd8OAJ+zdOf0/TRMk3s23vpBFcaNCE
         aUtsvHOAaai3aEL90+IVYdRv3qqjaf6ySuDdcDJQBJc4mY2uTWVYJzJiQotpf/slFohW
         s083d6/ZUmhDlH17L535ta6tKWT861HSL4gKSkhMvTvf1n09U/gslGBYCw0LWnok95C4
         /8Pe5YnbAF/XDFe4npWxD7QUSAJrs+uSPvlbgM9KToEinTruD+c9dThlk6LVPgsLXLzb
         Sm/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oDW0TM5d;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g81sor14235222itg.21.2019.04.08.11.29.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 11:29:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oDW0TM5d;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hsELHUWfDrJGX9dc+Y4VaPIgthl5gTtW1e2RiuINGDI=;
        b=oDW0TM5dUvQfrnJMzQddgz8+hJucu4gme/BAHOav/PIA4hMvHX8hm1YaYHCtlrBcMO
         h00DIAqldD8Olz/uc+jh4Gde+xYt39lkpMSSIwXUhSDOos6xyB9fE5nsD+UxuJWvUf+f
         t43afn/R9NpHJT+gSQF2Oe/GKRfmO9r+6W3dnE0W9d+73xk9qGOw03ojH0ITJODoGmBY
         fxXZQ9s4aMnYcOdoAHLdQjw5hQ64bjecDcsz2dxwYijYmnDYw6ZJguOZd94eU+HqB5OX
         UrGkYNm67UpMBBszXF2bR1qnM/7ojKc/E16ZfIOEY+JenicaKcDoyPbxs8BlhEkkj3w7
         Cvaw==
X-Google-Smtp-Source: APXvYqzEqs4xKJyPXc/oIY1JU1Aw/zbJmQrsBLmLuxxoaKnO2tg/XNMnR4OacBLhms597VmnW8A0eZEfGDWxRpIc2sE=
X-Received: by 2002:a24:4d06:: with SMTP id l6mr18679353itb.140.1554748168169;
 Mon, 08 Apr 2019 11:29:28 -0700 (PDT)
MIME-Version: 1.0
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <01d5f4e8-742b-33f5-6d91-0c7c396d1cfc@redhat.com> <6f097f31-abc7-f56c-199c-dc167331f6b9@redhat.com>
 <20190408141145-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190408141145-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 8 Apr 2019 11:29:17 -0700
Message-ID: <CAKgT0UekrBHW0LAwGpvJqLFfiw51e=_52858FCr9EW6nirW-QA@mail.gmail.com>
Subject: Re: Thoughts on simple scanner approach for free page hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 8, 2019 at 11:19 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Mon, Apr 08, 2019 at 02:09:59PM -0400, Nitesh Narayan Lal wrote:
> > On 4/8/19 12:36 PM, David Hildenbrand wrote:
> > > On 06.04.19 02:09, Alexander Duyck wrote:
> > >> So I am starting this thread as a spot to collect my thoughts on the
> > >> current guest free page hinting design as well as point out a few
> > >> possible things we could do to improve upon it.
> > >>
> > >> 1. The current design isn't likely going to scale well to multiple
> > >> VCPUs. The issue specifically is that the zone lock must be held to
> > >> pull pages off of the free list and to place them back there once they
> > >> have been hinted upon. As a result it would likely make sense to try
> > >> to limit ourselves to only having one thread performing the actual
> > >> hinting so that we can avoid running into issues with lock contention
> > >> between threads.
> > > Makes sense.
> > >
> > >> 2. There are currently concerns about the hinting triggering false OOM
> > >> situations if too much memory is isolated while it is being hinted. My
> > >> thought on this is to simply avoid the issue by only hint on a limited
> > >> amount of memory at a time. Something like 64MB should be a workable
> > >> limit without introducing much in the way of regressions. However as a
> > >> result of this we can easily be overrun while waiting on the host to
> > >> process the hinting request. As such we will probably need a way to
> > >> walk the free list and free pages after they have been freed instead
> > >> of trying to do it as they are freed.
> > > We will need such a way in case we care about dropped hinting requests, yes.
> > >
> > >> 3. Even with the current buffering which is still on the larger side
> > >> it is possible to overrun the hinting limits if something causes the
> > >> host to stall and a large swath of memory is released. As such we are
> > >> still going to need some sort of scanning mechanism or will have to
> > >> live with not providing accurate hints.
> > > Yes, usually if there is a lot of guest activity, you could however
> > > assume that free pages might get reused either way soon. Of course,
> > > special cases are "freeing XGB and being idle afterwards".
> > >
> > >> 4. In my opinion, the code overall is likely more complex then it
> > >> needs to be. We currently have 2 allocations that have to occur every
> > >> time we provide a hint all the way to the host, ideally we should not
> > >> need to allocate more memory to provide hints. We should be able to
> > >> hold the memory use for a memory hint device constant and simply map
> > >> the page address and size to the descriptors of the virtio-ring.
> > > I don't think the two allocations are that complex. The only thing I
> > > consider complex is isolation a lot of pages from different zones etc.
> > > Two allocations, nobody really cares about that. Of course, the fact
> > > that we have to allocate memory from the VCPUs where we currently freed
> > > a page is not optimal. I consider that rather a problem/complex.
> > >
> > > Especially you have a point regarding scalability and multiple VCPUs.
> > >
> > >> With that said I have a few ideas that may help to address the 4
> > >> issues called out above. The basic idea is simple. We use a high water
> > >> mark based on zone->free_area[order].nr_free to determine when to wake
> > >> up a thread to start hinting memory out of a given free area. From
> > >> there we allocate non-"Offline" pages from the free area and assign
> > >> them to the hinting queue up to 64MB at a time. Once the hinting is
> > >> completed we mark them "Offline" and add them to the tail of the
> > >> free_area. Doing this we should cycle the non-"Offline" pages slowly
> > >> out of the free_area. In addition the search cost should be minimal
> > >> since all of the "Offline" pages should be aggregated to the tail of
> > >> the free_area so all pages allocated off of the free_area will be the
> > >> non-"Offline" pages until we shift over to them all being "Offline".
> > >> This should be effective for MAX_ORDER - 1 and MAX_ORDER - 2 pages
> > >> since the only real consumer of add_to_free_area_tail is
> > >> __free_one_page which uses it to place a page with an order less than
> > >> MAX_ORDER - 2 on the tail of a free_area assuming that it should be
> > >> freeing the buddy of that page shortly. The only other issue with
> > >> adding to tail would be the memory shuffling which was recently added,
> > >> but I don't see that as being something that will be enabled in most
> > >> cases so we could probably just make the features mutually exclusive,
> > >> at least for now.
> > >>
> > >> So if I am not mistaken this would essentially require a couple
> > >> changes to the mm infrastructure in order for this to work.
> > >>
> > >> First we would need to split nr_free into two counters, something like
> > >> nr_freed and nr_bound. You could use nr_freed - nr_bound to get the
> > >> value currently used for nr_free. When we pulled the pages for hinting
> > >> we would reduce the nr_freed value and then add back to it when the
> > >> pages are returned. When pages are allocated they would increment the
> > >> nr_bound value. The idea behind this is that we can record nr_free
> > >> when we collect the pages and save it to some local value. This value
> > >> could then tell us how many new pages have been added that have not
> > >> been hinted upon.
> > > I can imagine that quite some people will have problems with such
> > > "virtualization specific changes" splattered around core memory
> > > management. Would there be a way to manage this data at a different
> > > place, out of core-mm and somehow work on it via callbacks?
> > >
> > >> In addition we will need some way to identify which pages have been
> > >> hinted on and which have not. The way I believe easiest to do this
> > >> would be to overload the PageType value so that we could essentially
> > >> have two values for "Buddy" pages. We would have our standard "Buddy"
> > >> pages, and "Buddy" pages that also have the "Offline" value set in the
> > >> PageType field. Tracking the Online vs Offline pages this way would
> > >> actually allow us to do this with almost no overhead as the mapcount
> > >> value is already being reset to clear the "Buddy" flag so adding a
> > >> "Offline" flag to this clearing should come at no additional cost.
> > > Just nothing here that this will require modifications to kdump
> > > (makedumpfile to be precise and the vmcore information exposed from the
> > > kernel), as kdump only checks for the the actual mapcount value to
> > > detect buddy and offline pages (to exclude them from dumps), they are
> > > not treated as flags.
> > >
> > > For now, any mapcount values are really only separate values, meaning
> > > not the separate bits are of interest, like flags would be. Reusing
> > > other flags would make our life a lot easier. E.g. PG_young or so. But
> > > clearing of these is then the problematic part.
> > >
> > > Of course we could use in the kernel two values, Buddy and BuddyOffline.
> > > But then we have to check for two different values whenever we want to
> > > identify a buddy page in the kernel.
> > >
> > >> Lastly we would need to create a specialized function for allocating
> > >> the non-"Offline" pages, and to tweak __free_one_page to tail enqueue
> > >> "Offline" pages. I'm thinking the alloc function it would look
> > >> something like __rmqueue_smallest but without the "expand" and needing
> > >> to modify the !page check to also include a check to verify the page
> > >> is not "Offline". As far as the changes to __free_one_page it would be
> > >> a 2 line change to test for the PageType being offline, and if it is
> > >> to call add_to_free_area_tail instead of add_to_free_area.
> > > As already mentioned, there might be scenarios where the additional
> > > hinting thread might consume too much CPU cycles, especially if there is
> > > little guest activity any you mostly spend time scanning a handful of
> > > free pages and reporting them. I wonder if we can somehow limit the
> > > amount of wakeups/scans for a given period to mitigate this issue.
> > >
> > > One main issue I see with your approach is that we need quite a lot of
> > > core memory management changes. This is a problem. I wonder if we can
> > > factor out most parts into callbacks.
> > >
> > > E.g. in order to detect where to queue a certain page (front/tail), call
> > > a callback if one is registered, mark/check pages in a core-mm unknown
> > > way as offline etc.
> > >
> > > I still wonder if there could be an easier way to combine recording of
> > > hints and one hinting thread, essentially avoiding scanning and some of
> > > the required core-mm changes.
> > In order to resolve the scalability issues associated with my
> > patch-series without compromising with free memory hints, I may explore
> > the idea described below:
> > - Use xbitmap (if possible - earlier suggested by Rik and Wei)
> > corresponding to each zone on a granularity of MAX_ORDER - 2, to track
> > the freed PFN's.
>
> MAX_ORDER - 2 is what? 2Mbyte?

Yeah, it should be 2MB assuming that MAX_ORDER - 1 is 4MB.

I'm still not a fan of us adding to much additional tracking data. The
problem with xbitmap is that you are going to have to protect that
with the zone lock and then scan it. Basically all you are going to do
is spread the pain out over all the allocate and free tasks since they
are going to have to update this bitmap now in addition to everything
else.

The way I see it we are adding additional overhead. We shouldn't need
much more than a single long per free_area that we maintain in the
virtio_balloon driver.

> > - Define and use counters corresponding to each zone to monitor the
> > amount of memory freed.
> > - As soon as the 64MB free memory threshold is hit wake up the kernel
> > thread which will scan this xbitmap and try to isolate the pages and
> > clear the corresponding bits. (We still have to acquire zone lock to
> > protect the respective xbitmap)
>
> So that's 32 pages then? I'd say just keep them in an array,
> list, tree or hash, bitmap is for when you have nots of pages.

The xbitmap I think is for the free page tracking. The problem is this
could build up to tons of pages while we are waiting on hints to
complete if we have a thread that is dumping a large amount of free
pages.

> > - Report the isolated pages back to the host in a synchronous manner.
> > I still have to work on several details of this idea including xbitmap,
> > but first would like to hear any suggestions/thoughts.

I'm still not a fan of trying to keep track of the free page metadata
in real-time. It is going to be far more expensive to have every free
and alloc have to update the extra piece of data than to just come
through after the fact and scan the new pages that have been added.

If we assume the free_area is populated such that the standard
alloc/free is always adding and removing from the head, then having
our offlining thread pulling from head and adding to tail would
naturally make things function such that our "walk" to get free pages
should be extremely inexpensive since head will always be the recent
stuff, and tail will build up with the offline stuff until there is no
recent stuff left and all the pages are offline.

