Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71E50C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:57:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F1162173C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:57:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VmdyRRhm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F1162173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C3188E0004; Tue, 12 Mar 2019 18:57:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 999978E0002; Tue, 12 Mar 2019 18:57:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AF6B8E0004; Tue, 12 Mar 2019 18:57:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64E458E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:57:04 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id v12so3569453itv.9
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:57:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jIFuwTaqlsPxroQheI+plV9ASZgtqzOS4PSZ00O/GCE=;
        b=mgQXI6bQhEOkAE6ULvA+DqTSiADuu2aaLEtSLBwPmcsZH+x3DzjvwNOKSF49u0n86u
         dtoYcHDb2VJZBjlb6Z7uDereMoaJZWqhtrCCZOiwPsgjsxA+eKO/MTxxJLZvijGmSVtN
         4CxKU5vCO/Bg5GIcE+Slec70Y87zNQtpBrdmyUT+8WurQSN+XFlx5GbLFEkHFjllee5Z
         kifZrINJ4GOO+XK7nt11UlKZ3sSiddin0QdLPa4HjbHHgmI52mx5pd478CMkGSmTxlEZ
         HhTmZ/ScaKvuIiNVj16/xqFEjnHP2ghcOFKAvIvl2MW4I7teP90bE1QcGiacUElp3ILm
         8Vog==
X-Gm-Message-State: APjAAAWV6YJiYWQqIvk24MaDKWfoIXDmeGeobfGICMdgWwvAMhvRhYuM
	jAU87HMIQU07/F6q+eJ6zac+z8jy5NRgD4xaHGC0R55Nf7lvVnI98j/FWpASetOa2dfJcbHEzUx
	BdrSMuUWYRxZetDWKIXrzzwxbLSwtM+6U8XLUpKMmKbya1Y13LBxj8qeVlY24x4BViXFIiaDgZ3
	Qc46O0wIpx48GQ/q+FAN7Kw8gEXn+iu28xLl5V42yU3sroTwwRJsiDAHV+vnBr2M/3jspHKfZp5
	wqoLbCg02Q2aphCCzvxEVybqDxWBKpQCLKPXz8dKUWnYuvvMgY6yo5B1HlKSW6AhrsLa5mJcli1
	Z9n0xKrgkN+2YTCutsWgq9/5GF8GTtNOjW+SE5zwwaxN5I0fNdweOpFAM9r5gVDwMh99XERryY1
	D
X-Received: by 2002:a02:5c5d:: with SMTP id q90mr22542096jab.43.1552431424107;
        Tue, 12 Mar 2019 15:57:04 -0700 (PDT)
X-Received: by 2002:a02:5c5d:: with SMTP id q90mr22542061jab.43.1552431423053;
        Tue, 12 Mar 2019 15:57:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552431423; cv=none;
        d=google.com; s=arc-20160816;
        b=BLHj3c1MxYIRa47X3KtviJVg3FLmjAy06Yp4kj78lJmZZJfEXCo3NtBIGlVkv1XtrJ
         /QuimbdbyoIl/QrWAoQnbUYS9bSBl/crehHfS2opMaV2cqvo+KEV5TCPKGStbNIPmCeT
         241nrwwKZRI/U8n+Zbov1MuBnFD1psdz2h1MbBTnoPLPa5OrYG6ZDUI2lxYrbA10fOjA
         h9tu9Qy1D0GWrRgtx5yJYeHa8ar2L4UYlg5+7OGjaIl0fYrVh+nRovSLSJDW/orMC9B2
         e9IpJ0HdeXPy954JCLZkpw/CE0jZbp0HenPx2DjsmFqiW+Nu6A7SnZNfabrHTun9CqQ0
         j3uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jIFuwTaqlsPxroQheI+plV9ASZgtqzOS4PSZ00O/GCE=;
        b=Xev62cu0Hrl1OGWr1ZSCeKrNxZoWqpM9fO9QmvFgekLWlHmR194BPIELM4iZXLKHC6
         aN1keoGkzHDVJnYJfBNhBQKMUn+PLT2cceXXnRXYGRxeJdvBlVqKNPsszMaJTDWh/RDm
         CwX1uWiGU4rrUS8RnTBMk80whZQiqHZKTtfa6BnTq4xvUrfuLrs4nL7SE64QMySN0JJE
         UxxQeaWEifKRLyIxO979LdacRaSWaAFzSrdCONUuPWh2LObtHiFC5dw1qG3ZzHkfJqs6
         jSpFgCDClmcsrHg/fn9QGDcNwO8/e1ulC9tpE2SGWhtKLI0eUEl4X6mXOBiFsfrqLl79
         Vh+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VmdyRRhm;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m47sor165876iti.2.2019.03.12.15.57.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 15:57:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VmdyRRhm;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jIFuwTaqlsPxroQheI+plV9ASZgtqzOS4PSZ00O/GCE=;
        b=VmdyRRhmKuHbcpkG8m+AVJpZeTLkgs88qJxqBQ80xUiEM1GRYFwMXtA2dx54CJ97AU
         CdUop5KWoTbZS/9dVAVE4JNnbeZwQDpZBFiUcv22IilkF0CId7GouHM2vn3i7QmWZynl
         g4t/HPIQjRG6htkap+SxSH9pZnUXevZAq94gvm1fB6tLu1MAk3HZ4gAF1Ffp+DFdNB9M
         UGxw0wcWjmH3wYPCBZeDHuUPaYt1y/7FK3+ZJmdMWIb2GXGBwTEr5L/EfiElTr8EuJQX
         07AO+k4CH2H5DLCRchY4oNhbCvaXcILrLeKI5MZEuHtRNJmB+IZwEdZ8nVWar2O3+b68
         epQw==
X-Google-Smtp-Source: APXvYqwL7Bqrcj7SXP29rOVcCDsjzWYenQ27zAqjv+O5kl+XPR3EpMGhyotzkBj4jLCYXb7avecbKU+9xy3Nz0cqQwQ=
X-Received: by 2002:a24:b643:: with SMTP id d3mr136826itj.146.1552431422559;
 Tue, 12 Mar 2019 15:57:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com> <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com> <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org> <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
 <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com> <CAKgT0UcdQZwHjmMBkSWmy_ZdShJCagjwomn13g+r7ZNJBRn1LQ@mail.gmail.com>
 <8f692047-4750-6827-1ee0-d3d354788f09@redhat.com> <CAKgT0UddT9CKg1uZo6ZODs9ARti-6XGm9Zvo+8QRZKUPSwzWMQ@mail.gmail.com>
 <41ae8afe-72c9-58e6-0cbb-9375c91ce37a@redhat.com> <CAKgT0Uftff+JVRW-sQ6u8DeVg4Fq9b-pgE6Ojr+XqQFn13JmGw@mail.gmail.com>
 <be257778-3ecb-8f12-2d51-451a5e16fd3f@redhat.com>
In-Reply-To: <be257778-3ecb-8f12-2d51-451a5e16fd3f@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 12 Mar 2019 15:56:51 -0700
Message-ID: <CAKgT0UfG6PQS-LTGGcGrV3Qi1eLAFxef=OV43SVThQVgFSMqRA@mail.gmail.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free pages
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>, 
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

On Tue, Mar 12, 2019 at 2:53 PM David Hildenbrand <david@redhat.com> wrote:
>
> On 12.03.19 22:13, Alexander Duyck wrote:
> > On Tue, Mar 12, 2019 at 12:46 PM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>
> >> On 3/8/19 4:39 PM, Alexander Duyck wrote:
> >>> On Fri, Mar 8, 2019 at 11:39 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>>> On 3/8/19 2:25 PM, Alexander Duyck wrote:
> >>>>> On Fri, Mar 8, 2019 at 11:10 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>>>>> On 3/8/19 1:06 PM, Alexander Duyck wrote:
> >>>>>>> On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> >>>>>>>> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
> >>>>>>>>> The only other thing I still want to try and see if I can do is to add
> >>>>>>>>> a jiffies value to the page private data in the case of the buddy
> >>>>>>>>> pages.
> >>>>>>>> Actually there's one extra thing I think we should do, and that is make
> >>>>>>>> sure we do not leave less than X% off the free memory at a time.
> >>>>>>>> This way chances of triggering an OOM are lower.
> >>>>>>> If nothing else we could probably look at doing a watermark of some
> >>>>>>> sort so we have to have X amount of memory free but not hinted before
> >>>>>>> we will start providing the hints. It would just be a matter of
> >>>>>>> tracking how much memory we have hinted on versus the amount of memory
> >>>>>>> that has been pulled from that pool.
> >>>>>> This is to avoid false OOM in the guest?
> >>>>> Partially, though it would still be possible. Basically it would just
> >>>>> be a way of determining when we have hinted "enough". Basically it
> >>>>> doesn't do us much good to be hinting on free memory if the guest is
> >>>>> already constrained and just going to reallocate the memory shortly
> >>>>> after we hinted on it. The idea is with a watermark we can avoid
> >>>>> hinting until we start having pages that are actually going to stay
> >>>>> free for a while.
> >>>>>
> >>>>>>>  It is another reason why we
> >>>>>>> probably want a bit in the buddy pages somewhere to indicate if a page
> >>>>>>> has been hinted or not as we can then use that to determine if we have
> >>>>>>> to account for it in the statistics.
> >>>>>> The one benefit which I can see of having an explicit bit is that it
> >>>>>> will help us to have a single hook away from the hot path within buddy
> >>>>>> merging code (just like your arch_merge_page) and still avoid duplicate
> >>>>>> hints while releasing pages.
> >>>>>>
> >>>>>> I still have to check PG_idle and PG_young which you mentioned but I
> >>>>>> don't think we can reuse any existing bits.
> >>>>> Those are bits that are already there for 64b. I think those exist in
> >>>>> the page extension for 32b systems. If I am not mistaken they are only
> >>>>> used in VMA mapped memory. What I was getting at is that those are the
> >>>>> bits we could think about reusing.
> >>>>>
> >>>>>> If we really want to have something like a watermark, then can't we use
> >>>>>> zone->free_pages before isolating to see how many free pages are there
> >>>>>> and put a threshold on it? (__isolate_free_page() does a similar thing
> >>>>>> but it does that on per request basis).
> >>>>> Right. That is only part of it though since that tells you how many
> >>>>> free pages are there. But how many of those free pages are hinted?
> >>>>> That is the part we would need to track separately and then then
> >>>>> compare to free_pages to determine if we need to start hinting on more
> >>>>> memory or not.
> >>>> Only pages which are isolated will be hinted, and once a page is
> >>>> isolated it will not be counted in the zone free pages.
> >>>> Feel free to correct me if I am wrong.
> >>> You are correct up to here. When we isolate the page it isn't counted
> >>> against the free pages. However after we complete the hint we end up
> >>> taking it out of isolation and returning it to the "free" state, so it
> >>> will be counted against the free pages.
> >>>
> >>>> If I am understanding it correctly you only want to hint the idle pages,
> >>>> is that right?
> >>> Getting back to the ideas from our earlier discussion, we had 3 stages
> >>> for things. Free but not hinted, isolated due to hinting, and free and
> >>> hinted. So what we would need to do is identify the size of the first
> >>> pool that is free and not hinted by knowing the total number of free
> >>> pages, and then subtract the size of the pages that are hinted and
> >>> still free.
> >> To summarize, for now, I think it makes sense to stick with the current
> >> approach as this way we can avoid any locking in the allocation path and
> >> reduce the number of hypercalls for a bunch of MAX_ORDER - 1 page.
> >
> > I'm not sure what you are talking about by "avoid any locking in the
> > allocation path". Are you talking about the spin on idle bit, if so
> > then yes. However I have been testing your patches and I was correct
> > in the assumption that you forgot to handle the zone lock when you
> > were freeing __free_one_page. I just did a quick copy/paste from your
> > zone lock handling from the guest_free_page_hinting function into the
> > release_buddy_pages function and then I was able to enable multiple
> > CPUs without any issues.
> >
> >> For the next step other than the comments received in the code and what
> >> I mentioned in the cover email, I would like to do the following:
> >> 1. Explore the watermark idea suggested by Alex and bring down memhog
> >> execution time if possible.
> >
> > So there are a few things that are hurting us on the memhog test:
> > 1. The current QEMU patch is only madvising 4K pages at a time, this
> > is disabling THP and hurts the test.
> >
> > 2. The fact that we madvise the pages away makes it so that we have to
> > fault the page back in in order to use it for the memhog test. In
> > order to avoid that penalty we may want to see if we can introduce
> > some sort of "timeout" on the pages so that we are only hinting away
> > old pages that have not been used for some period of time.
> >
> > 3. Currently we are still doing a large amount of processing in the
> > page free path. Ideally we should look at getting away from trying to
> > do so much per-cpu work and instead just have some small tasks that
> > put the data needed in the page, and then have a separate thread
> > walking the free_list checking that data, isolating the pages, hinting
> > them, and then returning them back to the free_list.
>
> This is highly debatable. Whenever the is concurrency, there is the need
> for locking (well, at least synchronization - maybe using existing locks
> like the zone lock). The other thread has to run somewhere. One thread
> per VCPU might not what we want ... sorting this out might be more
> complicated than it would seem. I would suggest to defer the discussion
> of this change to a later stage. It can be easily reworked later - in
> theory :)

I'm not suggesting anything too complex for now. I would be happy with
just using the zone lock. The only other thing we would really need to
make it work is some sort of bit we could set once a page has been
hinted, and cleared when it is allocated. I"m leaning toward
PG_owner_priv_1 at this point since it doesn't seem to be used in the
buddy allocator but is heavily used/re-purposed in multiple other
spots.

> 1 and 2 you mention are the lower hanging fruits that will definitely
> improve performance.

Agreed. Although the challenge with 2 is getting to the page later
instead of trying to immediately hint on the page we just freed. That
is why I still thing 3 is going to tie in closely with 2.

> --
>
> Thanks,
>
> David / dhildenb

