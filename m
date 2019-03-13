Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF0C5C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 22:54:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D5DE2146E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 22:54:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Zp2J1GBY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D5DE2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 119078E000B; Wed, 13 Mar 2019 18:54:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C8358E0001; Wed, 13 Mar 2019 18:54:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F20BC8E000B; Wed, 13 Mar 2019 18:54:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9A1F8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 18:54:52 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id x87so4213926ita.1
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:54:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hI97cvpiFwbqINqVuOvg/SoIet+VipX1FL8Sh+mhPSo=;
        b=d6hDrluKZtkqpU6A85JXMn9OIOYWiVFP3ZNaxB9FntNYb8iMS/UF+MrHsx+kKURA4/
         JpId+RMziUF9LU0AXeck3RyNf9x3qA2PAm3EfvHr15VLcOsguqfYCCQFxfBTeaRoMH03
         YDmaUAJ2UMSbsJUeeEEZJR4qnXsKfKTM/ri+5+iUA1fRH2IvxQlhHbehtAksp6c/kccW
         RcbW3cUvZv0pqyZreZTnf4iLHM00dsdeMB5EJ9Zw/pLm9H8oFHm3xETWDJJq1nlaKNWo
         cG211PAaPZRgWwnq7ZTpyj1dPLVZSnOXt6gwKjOHwmPm1M3mBSD73aFIkEgw/sRvde/w
         LBRA==
X-Gm-Message-State: APjAAAU/av//jidvQqJQD3rehhLTZ1KhBQN919DFrbe8uWyD55tqXA4n
	Vx3tu4XaofIcXYiTmFaGKbpdTA8OjAIztyzKC+1sILGI9UGydtU96fG1J3eqZtcTYh/0ONdkAau
	6ood8Ait0aZ5cVaBy9cjr+boREXI1nB1il5spoVfUxMJDOq3gOIyKj6ZEU2xDM+vUAw==
X-Received: by 2002:a24:3a8b:: with SMTP id m133mr364120itm.26.1552517692230;
        Wed, 13 Mar 2019 15:54:52 -0700 (PDT)
X-Received: by 2002:a24:3a8b:: with SMTP id m133mr364081itm.26.1552517690909;
        Wed, 13 Mar 2019 15:54:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552517690; cv=none;
        d=google.com; s=arc-20160816;
        b=C/AMl762knZapX4KmeEDmvzMEJ2SqRyrhU3P6hWCAvy9ySOTAC97uD3eVb7b5jn5pP
         95ezAKwqXTSh+TYBJmB9javO8H2QJtQS/YL67iWZMLh7IxeRuKSkb64B8aLt4/COK2Rj
         4Nt6Fcje1SizYgfa1kAZPdoeVmamhXCOTB7H+JoA4x3zIFo8OyfUxoksbZQ6s72dl633
         etPzrXZSPx4vuu4N+j/ZtNSSbQVWYpzydXjwLChnc577+bQGYfgwH9YVWWIPNq1EZX4U
         eNqsSc/VqOLge8RIknyyQQ1nOZsSQcQBqVPPEkKMeCmWvtFhY360atWVmYo5O2YUV4Ba
         PdGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hI97cvpiFwbqINqVuOvg/SoIet+VipX1FL8Sh+mhPSo=;
        b=Xt56R13D+02qsgfV7SKaX+Tu+ZoofycvnhyRe20iZhY2Trnm9+A3oc6PiHz4vABmNc
         XREaf53+Pm3VazAI9fnDiMnZ3IOS7iL1wGO8+guaukoYKPwBZd0a9Msvg21R0qLxl+j4
         BXoyaAEBBr7Bz09Zuhq1bNPi15+fI1pBqbqm7QEMrbyr0Gd9w8hCR01XHxsGKgluC70N
         VSAG36Twla8cyBvzFEuD2B3GzfosuJp96SGLsBi3jw5yjZnx6VIeZknP7vRHATX79J+o
         gpS1VKTACNCnqBWLfyj0UTji3bWvEmPlu0BhmsqAtaXx4IxnlcHc7ku4L2dN0kZsbGx0
         6oJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Zp2J1GBY;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11sor4643409iom.117.2019.03.13.15.54.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 15:54:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Zp2J1GBY;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hI97cvpiFwbqINqVuOvg/SoIet+VipX1FL8Sh+mhPSo=;
        b=Zp2J1GBY2PZdvuxBzucq8kmyE2K23CMXhXuNXjNf9fuzVrdXzVG3bdIjS1ZfdLV2S7
         ioJqAkwmRJxRnM/6NxN4YNhXarvNRZycnK9PUyPORbUfbn83YO9mEq5WLleJcIa7kmV+
         IDpKUAjRSz4X5FHid6/o8rK2E0vdQZUKvLElTmL+z9CzhK+UQ/zYUSexpZZqzB/06L2E
         BVJXVUKx0cy8/DTWQ9EwnQqUO3OMjodIrRO7thGrgIEvG0k1ba3JRVZf+/4QBC/I8Img
         U9yEI0gTt1KC+6SxErWgzD4UVhdAhkpWHrytgpWzyslbzkjpK1tvIACkSWxrOa9KxvdH
         AhNw==
X-Google-Smtp-Source: APXvYqw3ZG1UU10TbGzDdlbWYuEyTWhm3KqyAdd3EFS4onxj0uEyYP28T3Sv5yA4eD2RAwENvmxZHjtCNcvD0qbmPYg=
X-Received: by 2002:a6b:f70a:: with SMTP id k10mr15952688iog.68.1552517690436;
 Wed, 13 Mar 2019 15:54:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com> <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com> <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org> <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
 <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com> <CAKgT0UcdQZwHjmMBkSWmy_ZdShJCagjwomn13g+r7ZNJBRn1LQ@mail.gmail.com>
 <8f692047-4750-6827-1ee0-d3d354788f09@redhat.com> <CAKgT0UddT9CKg1uZo6ZODs9ARti-6XGm9Zvo+8QRZKUPSwzWMQ@mail.gmail.com>
 <41ae8afe-72c9-58e6-0cbb-9375c91ce37a@redhat.com> <CAKgT0Uftff+JVRW-sQ6u8DeVg4Fq9b-pgE6Ojr+XqQFn13JmGw@mail.gmail.com>
 <1ae522f1-1e98-9eef-324c-29585fe574d6@redhat.com> <8826829a-973d-8117-3fe3-8e33170acfb8@redhat.com>
 <CAKgT0UdGhFFR=SN8rdT5QMk-QF0LuWz0Xh2pp9abrfc3FgKmVQ@mail.gmail.com> <71d0bd98-ff97-7ed1-1f95-c0d134d0b2a1@redhat.com>
In-Reply-To: <71d0bd98-ff97-7ed1-1f95-c0d134d0b2a1@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 13 Mar 2019 15:54:39 -0700
Message-ID: <CAKgT0Uef=O3bSQLc6-JY8jLmmtOPFwVWSAsY+sHL=BocSGp8BQ@mail.gmail.com>
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

On Wed, Mar 13, 2019 at 9:39 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 13.03.19 17:37, Alexander Duyck wrote:
> > On Wed, Mar 13, 2019 at 5:18 AM David Hildenbrand <david@redhat.com> wrote:
> >>
> >> On 13.03.19 12:54, Nitesh Narayan Lal wrote:
> >>>
> >>> On 3/12/19 5:13 PM, Alexander Duyck wrote:
> >>>> On Tue, Mar 12, 2019 at 12:46 PM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>>>> On 3/8/19 4:39 PM, Alexander Duyck wrote:
> >>>>>> On Fri, Mar 8, 2019 at 11:39 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>>>>>> On 3/8/19 2:25 PM, Alexander Duyck wrote:
> >>>>>>>> On Fri, Mar 8, 2019 at 11:10 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>>>>>>>> On 3/8/19 1:06 PM, Alexander Duyck wrote:
> >>>>>>>>>> On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> >>>>>>>>>>> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
> >>>>>>>>>>>> The only other thing I still want to try and see if I can do is to add
> >>>>>>>>>>>> a jiffies value to the page private data in the case of the buddy
> >>>>>>>>>>>> pages.
> >>>>>>>>>>> Actually there's one extra thing I think we should do, and that is make
> >>>>>>>>>>> sure we do not leave less than X% off the free memory at a time.
> >>>>>>>>>>> This way chances of triggering an OOM are lower.
> >>>>>>>>>> If nothing else we could probably look at doing a watermark of some
> >>>>>>>>>> sort so we have to have X amount of memory free but not hinted before
> >>>>>>>>>> we will start providing the hints. It would just be a matter of
> >>>>>>>>>> tracking how much memory we have hinted on versus the amount of memory
> >>>>>>>>>> that has been pulled from that pool.
> >>>>>>>>> This is to avoid false OOM in the guest?
> >>>>>>>> Partially, though it would still be possible. Basically it would just
> >>>>>>>> be a way of determining when we have hinted "enough". Basically it
> >>>>>>>> doesn't do us much good to be hinting on free memory if the guest is
> >>>>>>>> already constrained and just going to reallocate the memory shortly
> >>>>>>>> after we hinted on it. The idea is with a watermark we can avoid
> >>>>>>>> hinting until we start having pages that are actually going to stay
> >>>>>>>> free for a while.
> >>>>>>>>
> >>>>>>>>>>  It is another reason why we
> >>>>>>>>>> probably want a bit in the buddy pages somewhere to indicate if a page
> >>>>>>>>>> has been hinted or not as we can then use that to determine if we have
> >>>>>>>>>> to account for it in the statistics.
> >>>>>>>>> The one benefit which I can see of having an explicit bit is that it
> >>>>>>>>> will help us to have a single hook away from the hot path within buddy
> >>>>>>>>> merging code (just like your arch_merge_page) and still avoid duplicate
> >>>>>>>>> hints while releasing pages.
> >>>>>>>>>
> >>>>>>>>> I still have to check PG_idle and PG_young which you mentioned but I
> >>>>>>>>> don't think we can reuse any existing bits.
> >>>>>>>> Those are bits that are already there for 64b. I think those exist in
> >>>>>>>> the page extension for 32b systems. If I am not mistaken they are only
> >>>>>>>> used in VMA mapped memory. What I was getting at is that those are the
> >>>>>>>> bits we could think about reusing.
> >>>>>>>>
> >>>>>>>>> If we really want to have something like a watermark, then can't we use
> >>>>>>>>> zone->free_pages before isolating to see how many free pages are there
> >>>>>>>>> and put a threshold on it? (__isolate_free_page() does a similar thing
> >>>>>>>>> but it does that on per request basis).
> >>>>>>>> Right. That is only part of it though since that tells you how many
> >>>>>>>> free pages are there. But how many of those free pages are hinted?
> >>>>>>>> That is the part we would need to track separately and then then
> >>>>>>>> compare to free_pages to determine if we need to start hinting on more
> >>>>>>>> memory or not.
> >>>>>>> Only pages which are isolated will be hinted, and once a page is
> >>>>>>> isolated it will not be counted in the zone free pages.
> >>>>>>> Feel free to correct me if I am wrong.
> >>>>>> You are correct up to here. When we isolate the page it isn't counted
> >>>>>> against the free pages. However after we complete the hint we end up
> >>>>>> taking it out of isolation and returning it to the "free" state, so it
> >>>>>> will be counted against the free pages.
> >>>>>>
> >>>>>>> If I am understanding it correctly you only want to hint the idle pages,
> >>>>>>> is that right?
> >>>>>> Getting back to the ideas from our earlier discussion, we had 3 stages
> >>>>>> for things. Free but not hinted, isolated due to hinting, and free and
> >>>>>> hinted. So what we would need to do is identify the size of the first
> >>>>>> pool that is free and not hinted by knowing the total number of free
> >>>>>> pages, and then subtract the size of the pages that are hinted and
> >>>>>> still free.
> >>>>> To summarize, for now, I think it makes sense to stick with the current
> >>>>> approach as this way we can avoid any locking in the allocation path and
> >>>>> reduce the number of hypercalls for a bunch of MAX_ORDER - 1 page.
> >>>> I'm not sure what you are talking about by "avoid any locking in the
> >>>> allocation path". Are you talking about the spin on idle bit, if so
> >>>> then yes.
> >>> Yeap!
> >>>> However I have been testing your patches and I was correct
> >>>> in the assumption that you forgot to handle the zone lock when you
> >>>> were freeing __free_one_page.
> >>> Yes, these are the steps other than the comments you provided in the
> >>> code. (One of them is to fix release_buddy_page())
> >>>>  I just did a quick copy/paste from your
> >>>> zone lock handling from the guest_free_page_hinting function into the
> >>>> release_buddy_pages function and then I was able to enable multiple
> >>>> CPUs without any issues.
> >>>>
> >>>>> For the next step other than the comments received in the code and what
> >>>>> I mentioned in the cover email, I would like to do the following:
> >>>>> 1. Explore the watermark idea suggested by Alex and bring down memhog
> >>>>> execution time if possible.
> >>>> So there are a few things that are hurting us on the memhog test:
> >>>> 1. The current QEMU patch is only madvising 4K pages at a time, this
> >>>> is disabling THP and hurts the test.
> >>> Makes sense, thanks for pointing this out.
> >>>>
> >>>> 2. The fact that we madvise the pages away makes it so that we have to
> >>>> fault the page back in in order to use it for the memhog test. In
> >>>> order to avoid that penalty we may want to see if we can introduce
> >>>> some sort of "timeout" on the pages so that we are only hinting away
> >>>> old pages that have not been used for some period of time.
> >>>
> >>> Possibly using MADVISE_FREE should also help in this, I will try this as
> >>> well.
> >>
> >> I was asking myself some time ago how MADVISE_FREE will be handled in
> >> case of THP. Please let me know your findings :)
> >
> > The problem with MADVISE_FREE is that it will add additional
> > complication to the QEMU portion of all this as it only applies to
> > anonymous memory if I am not mistaken.
>
> Just as MADV_DONTNEED. So nothing new. Future work.

I'm pretty sure you can use MADV_DONTNEED to free up file backed
memory, I don't believe this is the case for MADV_FREE, but maybe I am
mistaken.

On a side note I was just reviewing some stuff related to the reserved
bit and on-lining hotplug memory, and it just occurred to me that most
the PG_offline bit would be a good means to indicate that we hinted
away a page out of the buddy allocator, especially since it is already
used by the balloon drivers anyway.  We would just have to add a call
to make sure we clear it when we call __ClearPageBuddy. It looks like
that would currently be in del_page_from_free_area, at least for
linux-next.

I just wanted to get your thoughts on that as it seems like it might
be a good fit.

Thanks.

- Alex

