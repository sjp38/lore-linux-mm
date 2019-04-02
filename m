Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0EC0C10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 17:30:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 561D52084B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 17:30:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RrDSZQEe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 561D52084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A542F6B0269; Tue,  2 Apr 2019 13:30:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A03416B026F; Tue,  2 Apr 2019 13:30:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F3296B0270; Tue,  2 Apr 2019 13:30:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA256B0269
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 13:30:44 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id m128so3501356itm.6
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 10:30:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Rho5aq2RUdzp4rI0pKv1PGDGCGwbl54PvFd97JZCy4o=;
        b=T96HVzNLhOYlxDafmSPHR0uepilTJ2eMPeCfIyYZF2pl7BWEBW0DfZgIJbZ1uSffXd
         u0eolsghKFEwyjLJHx4P3gDPtx5NmVkJSyv0FAEDSm3tw3LjRGh7Tc+ahN0l4VdJM21B
         pkP6fcNexX3TENGak7GlKu07B+F7BIb82jog8cvNIG5w4sHRCu8HEh83Lfq1uGmLnUjE
         cpL+f3ZolrnCgvSH16Z/sT9t4okGNhrOxgyOYKTL3Ny1esCpaPr6mpFHfjMlsqJ53XTg
         ckwfF23TbaPLQ+HruVN8+cYClt+rLLoOkJlFrF9V6HuCV9bK4Rdulb6Dyc9C8gnsWrep
         2mSQ==
X-Gm-Message-State: APjAAAUypRpHWk+oo4uTj1xYYkiRmWqu2f1tp1Fsz8xm26b8pLF2WSWB
	fyFXplXl0gmS42sMAiPY5eB85Hywx1AePViiDTi4mEM6JIxHt/13JQCuNy8qid+60j1fC9NwAHG
	P+fax7gNLJAZS/SKy0gxKzCfO710EMQLWv9v4J+j4KMpPzCJ/sC1tNkPrIiow0P3Rtg==
X-Received: by 2002:a5d:9914:: with SMTP id x20mr15150719iol.257.1554226244121;
        Tue, 02 Apr 2019 10:30:44 -0700 (PDT)
X-Received: by 2002:a5d:9914:: with SMTP id x20mr15150634iol.257.1554226242645;
        Tue, 02 Apr 2019 10:30:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554226242; cv=none;
        d=google.com; s=arc-20160816;
        b=pwIzblEmzVO8h8HyRBfJHFrg0cBZzTZUZRKlEboI3V0LcOgjtJ2wcezEaXLygQSA2S
         5e85FQyFGt6Og4XuUMicOL8JfizmLt9BVQQIqStRgsYKn5A0HFf6Rau5m+hGvJgzmHq/
         kM27M627VSUmlOAJee6yJ1SOgEjUuPJoTuxyQJgpdk+v7mMAcPZkOiMlip2mTROmxJV4
         V2zfe6CN/8K3JJx1RSZ+YeQwjc5qLEJ5xgzsnvkTS9icZXsbiSDTFIDewxLBUjIHjced
         AU75efBYW/dyv8sdtAbMyBdjaUIp9Ix4fP1N5tzLwA4TgE7YH+JfhGEC8vFjD0VsiiCr
         Kxkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Rho5aq2RUdzp4rI0pKv1PGDGCGwbl54PvFd97JZCy4o=;
        b=mkHy9jZmxyhV1Sn6oXAexGCF0G+cH7KbidZencET+HjLk8bGhjxNkrOyZDjY+X5pwC
         Gem+VtK7hqb7KJkrNmbB0CHDSnB3jRjBjHE7OjkDXSgppVEXvK84Gy42ayE46+Cy827S
         e45OLBDjjlLham4w1ks7YMCSSrPxCTAKUybHCZoS64+eedWLVg2hFuEinLioRuUe2Z67
         Pl9d3MCuAILr0bmXtzD3ou7dtoKAoNzEmOHoV4TftQqFFDY6FtUOY2XWWg72Evu646/C
         QkUvBSqe6S8MwRp7QdNAnDu8IyyHUXEkslbr2lXEooyK+OpIZj2Uk+yZrsUhnp/LEnbU
         J8UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RrDSZQEe;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y72sor22899705itb.11.2019.04.02.10.30.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 10:30:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RrDSZQEe;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Rho5aq2RUdzp4rI0pKv1PGDGCGwbl54PvFd97JZCy4o=;
        b=RrDSZQEeY0idfa7vDPxrVqkl+9j7+LzgWeFmNpp71H99DpY/g8zJkNzGHPAZ28pYSd
         Cr23JV8VlSfHZhjkYrFO5vqMgVWNB6OL1Y1/+GUE08gBKB+6S/K3zi/EllCx8DJxWbtB
         6zL+ZweS0m39EIItDbyVHCEeo3q9NZLkUJj375pS2OWj+hdfWRYgleAuupL7Q4iZquwT
         Q11qzE8VuHMr5KeWO/w1lTLE2ldeJpOQleTzHDrBVrkg3cw35O9fhs9/psWn9sUmQooO
         bQHNyXeu5PZtU5OJnZSGqq/buA+PnTp7ZW3rzz2MRZHMrUitPU+lFM+vxZ+xF47cWyAw
         5EmQ==
X-Google-Smtp-Source: APXvYqw8gj7u+b2LvbL4Iow2UukuVehrV90NTc/BfRtOBt6BIn8tBF4EQ3JmbRq2V0ZIkIH6Hc56s7yNq/kqNH+IKe8=
X-Received: by 2002:a05:660c:243:: with SMTP id t3mr5276263itk.124.1554226242061;
 Tue, 02 Apr 2019 10:30:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com> <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com> <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org> <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org> <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com> <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com> <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
 <1249f9dd-d22d-9e19-ee33-767581a30021@redhat.com>
In-Reply-To: <1249f9dd-d22d-9e19-ee33-767581a30021@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 2 Apr 2019 10:30:30 -0700
Message-ID: <CAKgT0UeqX8Q8BYAo4COfQ2TQGBduzctAf5Ko+0mUmSw-aemOSg@mail.gmail.com>
Subject: Re: On guest free page hinting and OOM
To: David Hildenbrand <david@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
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

On Tue, Apr 2, 2019 at 8:56 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 02.04.19 17:04, Alexander Duyck wrote:
> > On Tue, Apr 2, 2019 at 12:42 AM David Hildenbrand <david@redhat.com> wrote:
> >>
> >> On 01.04.19 22:56, Alexander Duyck wrote:
> >>> On Mon, Apr 1, 2019 at 7:47 AM Michael S. Tsirkin <mst@redhat.com> wrote:
> >>>>
> >>>> On Mon, Apr 01, 2019 at 04:11:42PM +0200, David Hildenbrand wrote:
> >>>>>> The interesting thing is most probably: Will the hinting size usually be
> >>>>>> reasonable small? At least I guess a guest with 4TB of RAM will not
> >>>>>> suddenly get a hinting size of hundreds of GB. Most probably also only
> >>>>>> something in the range of 1GB. But this is an interesting question to
> >>>>>> look into.
> >>>>>>
> >>>>>> Also, if the admin does not care about performance implications when
> >>>>>> already close to hinting, no need to add the additional 1Gb to the ram size.
> >>>>>
> >>>>> "close to OOM" is what I meant.
> >>>>
> >>>> Problem is, host admin is the one adding memory. Guest admin is
> >>>> the one that knows about performance.
> >>>
> >>> The thing we have to keep in mind with this is that we are not dealing
> >>> with the same behavior as the balloon driver. We don't need to inflate
> >>> a massive hint and hand that off. Instead we can focus on performing
> >>> the hints on much smaller amounts and do it incrementally over time
> >>> with the idea being as the system sits idle it frees up more and more
> >>> of the inactive memory on the system.
> >>>
> >>> With that said, I still don't like the idea of us even trying to
> >>> target 1GB of RAM for hinting. I think it would be much better if we
> >>> stuck to smaller sizes and kept things down to a single digit multiple
> >>> of THP or higher order pages. Maybe something like 64MB of total
> >>> memory out for hinting.
> >>
> >> 1GB was just a number I came up with. But please note, as VCPUs hint in
> >> parallel, even though each request is only 64MB in size, things can sum up.
> >
> > Why do we need them running in parallel for a single guest? I don't
> > think we need the hints so quickly that we would need to have multiple
> > VCPUs running in parallel to provide hints. In addition as it
> > currently stands in order to get pages into and out of the buddy
> > allocator we are going to have to take the zone lock anyway so we
> > could probably just assume a single thread for pulling the memory,
> > placing it on the ring, and putting it back into the buddy allocator
> > after the hint has been completed.
>
> VCPUs hint when they think the time has come. Hinting in parallel comes
> naturally.

Actually it doesn't because if we are doing it asynchronously we are
having to pull pages out of the zone which requires the zone lock.
That has been one of the reasons why the patches from Nitesh start
dropping in performance when you start enabling more than 1 VCPU. If
we are limited by the zone lock it doesn't make sense for us to try to
do thing in parallel.

> >
> >>>
> >>> All we really would need to make it work would be to possibly look at
> >>> seeing if we can combine PageType values. Specifically what I would be
> >>> looking at is a transition that looks something like Buddy -> Offline
> >>> -> (Buddy | Offline). We would have to hold the zone lock at each
> >>> transition, but that shouldn't be too big of an issue. If we are okay
> >>> with possibly combining the Offline and Buddy types we would have a
> >>> way of tracking which pages have been hinted and which have not. Then
> >>> we would just have to have a thread running in the background on the
> >>> guest that is looking at the higher order pages and pulling 64MB at a
> >>> time offline, and when the hinting is done put them back in the "Buddy
> >>> | Offline" state.
> >>
> >> That approach may have other issues to solve (1 thread vs. many VCPUs,
> >> scanning all buddy pages over and over again) and other implications
> >> that might be undesirable (hints performed even more delayed, additional
> >> thread activity). I wouldn't call it the ultimate solution.
> >
> > So the problem with trying to provide the hint sooner is that you end
> > up creating a bottle-neck or you end up missing hints on pages
> > entirely and then have to fall back to such an approach. By just
> > letting the thread run in the background reporting the idle memory we
> > can avoid much of that.
> >
> > Also there isn't a huge priority to report idle memory in real time.
> > That would be kind of pointless as it might be pulled back out and
> > reused as soon as it is added. What we need is to give the memory a
> > bit of time to "cool" so that we aren't constantly hinting away memory
> > that is still in use.
>
> Depending on the setup, you don't want free memory lying around for too
> long in your guest.

Right, but you don't need it as soon as it is freed either. If it is
idle in the guest for a few seconds that shouldn't be an issue. The
free page hinting will hurt performance if we are doing it too often
simply because we are going to be triggering a much higher rate of
page faults.

> >
> >> Your approach sounds very interesting to play with, however
> >> at this point I would like to avoid throwing away Nitesh work once again
> >> to follow some other approach that looks promising. If we keep going
> >> like that, we'll spend another ~10 years working on free page hinting
> >> without getting anything upstream. Especially if it involves more
> >> core-MM changes. We've been there, we've done that. As long as the
> >> guest-host interface is generic enough, we can play with such approaches
> >> later in the guest. Important part is that the guest-host interface
> >> allows for that.
> >
> > I'm not throwing anything away. One of the issues in Nitesh's design
> > is that he is going to either miss memory and have to run an
> > asynchronous thread to clean it up after the fact, or he is going to
> > cause massive OOM errors and/or have to start halting VCPUs while
>
> 1. how are we going to miss memory. We are going to miss memory because
> we hint on very huge chunks, but we all agreed to live with that for now.

What I am talking about is that some application frees gigabytes of
memory. As I recall the queue length for a single cpu is only like 1G.
Are we going to be sitting on the backlog of most of system memory
while we process it 1G at a time?

> 2. What are the "massive OOM" errors you are talking about? We have the
> one scenario we described Nitesh was not even able to reproduce yet. And
> we have ways to mitigate the problem (discussed in this thread).

So I am referring to the last patch set I have seen. Last I knew all
the code was doing was assembling lists if isolated pages and placing
them on a queue. I have seen no way that this really limits the length
of the virtqueue, and the length of the isolated page lists is the
only thing that has any specific limits to it. So I see it easily
being possible for a good portion of memory being consumed by the
queue when you consider that what you have is essentially the maximum
length of the isolated page list multiplied by the number of entries
in a virtqueue.

> We have something that seems to work. Let's work from there instead of
> scrapping the general design once more, thinking "it is super easy". And
> yes, what you propose is pretty much throwing away the current design in
> the guest.

Define "work"? The last patch set required massive fixes as it was
causing kernel panics if more than 1 VCPU was enabled and list
corruption in general. I'm sure there are a ton more bugs lurking as
we have only begun to be able to stress this code in any meaningful
way.

For example what happens if someone sits on the mm write semaphore for
an extended period of time on the host? That will shut down all of the
hinting until that is released, and at that point once again any
hinting queues will be stuck on the guest until they can be processed
by the host.

> > waiting on the processing. All I am suggesting is that we can get away
> > from having to deal with both by just walking through the free pages
> > for the higher order and hinting only a few at a time without having
> > to try to provide the host with the hints on what is idle the second
> > it is freed.
> >
> >>>
> >>> I view this all as working not too dissimilar to how a standard Rx
> >>> ring in a network device works. Only we would want to allocate from
> >>> the pool of "Buddy" pages, flag the pages as "Offline", and then when
> >>> the hint has been processed we would place them back in the "Buddy"
> >>> list with the "Offline" value still set. The only real changes needed
> >>> to the buddy allocator would be to add some logic for clearing/merging
> >>> the "Offline" setting as necessary, and to provide an allocator that
> >>> only works with non-"Offline" pages.
> >>
> >> Sorry, I had to smile at the phrase "only" in combination with "provide
> >> an allocator that only works with non-Offline pages" :) . I guess you
> >> realize yourself that these are core-mm changes that might easily be
> >> rejected upstream because "the virt guys try to teach core-MM yet
> >> another special case". I agree that this is nice to play with,
> >> eventually that approach could succeed and be accepted upstream. But I
> >> consider this long term work.
> >
> > The actual patch for this would probably be pretty small and compared
> > to some of the other stuff that has gone in recently isn't too far out
> > of the realm of possibility. It isn't too different then the code that
> > has already done in to determine the unused pages for virtio-balloon
> > free page hinting.
> >
> > Basically what we would be doing is providing a means for
> > incrementally transitioning the buddy memory into the idle/offline
> > state to reduce guest memory overhead. It would require one function
> > that would walk the free page lists and pluck out pages that don't
> > have the "Offline" page type set, a one-line change to the logic for
> > allocating a page as we would need to clear that extra bit of state,
> > and optionally some bits for how to handle the merge of two "Offline"
> > pages in the buddy allocator (required for lower order support). It
> > solves most of the guest side issues with the free page hinting in
> > that trying to do it via the arch_free_page path is problematic at
> > best since it was designed for a synchronous setup, not an
> > asynchronous one.
>
> This is throwing away work. No I don't think this is the right path to
> follow for now. Feel free to look into it while Nitesh gets something in
> shape we know conceptually works and we are starting to know which
> issues we are hitting.

Yes, it is throwing away work. But if the work is running toward a
dead end does it add any value?

I've been looking into the stuff Nitesh has been doing. I don't know
about others, but I have been testing it. That is why I provided the
patches I did to get it stable enough for me to test and address the
regressions it was causing. That is the source of some of my concern.
I think we have been making this overly complex with all the per-cpu
bits and trying to place this in the free path itself. We really need
to scale this back and look at having a single thread with a walker of
some sort just hinting on what memory is sitting in the buddy but not
hinted on. It is a solution that would work, even in a multiple VCPU
case, and is achievable in the short term.

