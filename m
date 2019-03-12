Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5E47C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:13:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 650BC2147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:13:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TqRyxSi9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 650BC2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECB4F8E0004; Tue, 12 Mar 2019 17:13:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E55248E0002; Tue, 12 Mar 2019 17:13:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1E2C8E0004; Tue, 12 Mar 2019 17:13:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3DBE8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:13:45 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id 142so3394928itx.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:13:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ph/nRcOQwIH7Iz18D0S3VCpv2XhAxXLbQaFu6XqKiBI=;
        b=Usl93Iclwlj5P+pHks5kDWoo+dj+3yfgyU2hOBJSWa5Css2ZB3x5tVWTC0GqcSYBRt
         vI74Oeez1Lm1Mnyr4/lcfeSiEt0MtwMWS63HpySS2161dYbhUSQa1YCkluJQR1ahAufw
         zylcgsdRgJ23rmtxk77tRB9LMvFFXokv1786seTb0G9K2XMdqj3BZ5zSM1kQxT7i+peN
         3Qu7bzP1bahFLr+O8wFsbW4w4oMcjjEFUfA8LEePf/7CwuzMApkNlCqD3E7l0ZyvypUB
         i/BieihN0zL3/cCK61nAjaY2gPKGRXRAe/IEn4aD8bpJt7+QbsjMEvGRcJlL53Yudtdz
         l46Q==
X-Gm-Message-State: APjAAAUmxEmpQ4G2AqiCR4mT227/zvEpLbfSszGpYHJqzoLsGoLKbi1i
	SDlhduAiTCLamfUKm/zCEjRf2ufp0o3dfvOzpX5c1Iyj3nsCou5NB4RRLmQtSHqMN0WNLlirj0J
	Yus5QWQQi4nhHAIdrn2SJqGOxS2gNrMfjubX3YykiqHqX9X7YsQj0B1Rt6FBNVeFs2DY5a9pJM1
	lNSBMFm8bJnj9DiDJ0t9IL9AqRWzaLEkKWKcx39BQ6yBSvkw4jRcJb53qgI0NPlguZKthqfodMt
	vu1UL3XYUWFReG25WsBwsNqeu3OvFjSLnhXhty/1HAnlN9xFT8f2EUTCHro+bN0uvj28R7+1Mqs
	zRodkYaL48dg018ZdoMNOnkkMyBvMTMTYvFxkcJjAwC20TbSG9ywyZkTjrnP1YDwDfKnecH20S9
	R
X-Received: by 2002:a24:2b08:: with SMTP id h8mr3414502ita.13.1552425225401;
        Tue, 12 Mar 2019 14:13:45 -0700 (PDT)
X-Received: by 2002:a24:2b08:: with SMTP id h8mr3414451ita.13.1552425223991;
        Tue, 12 Mar 2019 14:13:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552425223; cv=none;
        d=google.com; s=arc-20160816;
        b=bZ+nWP2PAe4o3ThCNgymnXbqwNghcVKxLfFEZi5pqOCcbVqPA1GlawvKX4qLpvScco
         cCO65fbfJTaLixwSk4rqqmLCfgpCjw3efx8ll73WJUA65JxpSCOz8T9pNixM9IBPObus
         GJqJ/bCRuGy2kHTfgCwHwslFHPRnaYpo5Aq1XZXhBDzKyHChNYl7XibBfQDBiXauWdMA
         G5GdRMSYYxgmJcdT5Jgwy/TXEkXmkH1b1LmGIoOiH6Y+mEJ8Mog15nzvbJhfGc62+vv/
         J8hMZHHoHAX/gCr1MQ0yBs+D2j2gW/OtFotKs65Q4DcHFmzqeGHivd39Y59QaSvcC39g
         5yBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ph/nRcOQwIH7Iz18D0S3VCpv2XhAxXLbQaFu6XqKiBI=;
        b=GGuAkBjTlB7kzQd7a8YMbedrARj9lv1RmD5IlW2WLWWD7d7FHaOv2l41RRbBsjTsAc
         6CK06tVOUTOQzInI1l6x4gYq4D7abj4z3bXk/nixLuOfkX+8R7VqWwX7GDQZTslWmOcw
         IqQRRqOGE1zh/mYlOPOwlJUf7TBeC43S3aqdPPSkWcOP8u8/7rm4wqyV3pU94sGy3ii4
         XL987sxN17ayzxDB7n1wyZgoZvEjo0cks4pgbgwTBIYmhK5ZY48C0zEzzyivl0mKjIRb
         0Yi/KgxcRbvVqO4K3hCQanRrqrTOno3SmxU2f+jdHEv2hSfnHxw5hAtLD6JAbvjgTvFa
         d8WA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TqRyxSi9;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11sor2784044iom.117.2019.03.12.14.13.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 14:13:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TqRyxSi9;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ph/nRcOQwIH7Iz18D0S3VCpv2XhAxXLbQaFu6XqKiBI=;
        b=TqRyxSi9sgw9xEzqbjSt0EEbwLKM1pM/ZbqEE4V0pc9PCO3Q+BTAzqj8it9S5AHKS0
         i5dhe23tB6ve6htzSECsVwxa3NsgQe+DDvuQjxAXCgxbyTeuanXQUm7LnBR/Rfh+UGwm
         TFLmf/d9msEyAlGkDL6F7iageyZZutX0N/sMFplKPUGI5Xq2Rc8+NdzLGfEEfQQODNZM
         R66S/qBBanM6Uk/LtZnwI7ol6q/Bg7Ltuk141z4eZNbVUC392qUliHGmkR2rTWQImyN2
         baMVRFC3RlqtSvDiCyqAdYor0PCAfSzk4AtnvTtdzNxW8bHqtKjaL5jplRxbgbnNtP9Q
         XJXQ==
X-Google-Smtp-Source: APXvYqx6R5ALQ8xlR7Z+gpbB5yvLIqFRPtHR07v30jkWssK+SjaxmwmxEvkRl8Wv8tr3RjGNinik8wSRnw6SttmpnMY=
X-Received: by 2002:a6b:f70a:: with SMTP id k10mr12242291iog.68.1552425223444;
 Tue, 12 Mar 2019 14:13:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com> <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com> <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org> <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
 <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com> <CAKgT0UcdQZwHjmMBkSWmy_ZdShJCagjwomn13g+r7ZNJBRn1LQ@mail.gmail.com>
 <8f692047-4750-6827-1ee0-d3d354788f09@redhat.com> <CAKgT0UddT9CKg1uZo6ZODs9ARti-6XGm9Zvo+8QRZKUPSwzWMQ@mail.gmail.com>
 <41ae8afe-72c9-58e6-0cbb-9375c91ce37a@redhat.com>
In-Reply-To: <41ae8afe-72c9-58e6-0cbb-9375c91ce37a@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 12 Mar 2019 14:13:31 -0700
Message-ID: <CAKgT0Uftff+JVRW-sQ6u8DeVg4Fq9b-pgE6Ojr+XqQFn13JmGw@mail.gmail.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free pages
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>, 
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

On Tue, Mar 12, 2019 at 12:46 PM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
> On 3/8/19 4:39 PM, Alexander Duyck wrote:
> > On Fri, Mar 8, 2019 at 11:39 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >> On 3/8/19 2:25 PM, Alexander Duyck wrote:
> >>> On Fri, Mar 8, 2019 at 11:10 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>>> On 3/8/19 1:06 PM, Alexander Duyck wrote:
> >>>>> On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> >>>>>> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
> >>>>>>> The only other thing I still want to try and see if I can do is to add
> >>>>>>> a jiffies value to the page private data in the case of the buddy
> >>>>>>> pages.
> >>>>>> Actually there's one extra thing I think we should do, and that is make
> >>>>>> sure we do not leave less than X% off the free memory at a time.
> >>>>>> This way chances of triggering an OOM are lower.
> >>>>> If nothing else we could probably look at doing a watermark of some
> >>>>> sort so we have to have X amount of memory free but not hinted before
> >>>>> we will start providing the hints. It would just be a matter of
> >>>>> tracking how much memory we have hinted on versus the amount of memory
> >>>>> that has been pulled from that pool.
> >>>> This is to avoid false OOM in the guest?
> >>> Partially, though it would still be possible. Basically it would just
> >>> be a way of determining when we have hinted "enough". Basically it
> >>> doesn't do us much good to be hinting on free memory if the guest is
> >>> already constrained and just going to reallocate the memory shortly
> >>> after we hinted on it. The idea is with a watermark we can avoid
> >>> hinting until we start having pages that are actually going to stay
> >>> free for a while.
> >>>
> >>>>>  It is another reason why we
> >>>>> probably want a bit in the buddy pages somewhere to indicate if a page
> >>>>> has been hinted or not as we can then use that to determine if we have
> >>>>> to account for it in the statistics.
> >>>> The one benefit which I can see of having an explicit bit is that it
> >>>> will help us to have a single hook away from the hot path within buddy
> >>>> merging code (just like your arch_merge_page) and still avoid duplicate
> >>>> hints while releasing pages.
> >>>>
> >>>> I still have to check PG_idle and PG_young which you mentioned but I
> >>>> don't think we can reuse any existing bits.
> >>> Those are bits that are already there for 64b. I think those exist in
> >>> the page extension for 32b systems. If I am not mistaken they are only
> >>> used in VMA mapped memory. What I was getting at is that those are the
> >>> bits we could think about reusing.
> >>>
> >>>> If we really want to have something like a watermark, then can't we use
> >>>> zone->free_pages before isolating to see how many free pages are there
> >>>> and put a threshold on it? (__isolate_free_page() does a similar thing
> >>>> but it does that on per request basis).
> >>> Right. That is only part of it though since that tells you how many
> >>> free pages are there. But how many of those free pages are hinted?
> >>> That is the part we would need to track separately and then then
> >>> compare to free_pages to determine if we need to start hinting on more
> >>> memory or not.
> >> Only pages which are isolated will be hinted, and once a page is
> >> isolated it will not be counted in the zone free pages.
> >> Feel free to correct me if I am wrong.
> > You are correct up to here. When we isolate the page it isn't counted
> > against the free pages. However after we complete the hint we end up
> > taking it out of isolation and returning it to the "free" state, so it
> > will be counted against the free pages.
> >
> >> If I am understanding it correctly you only want to hint the idle pages,
> >> is that right?
> > Getting back to the ideas from our earlier discussion, we had 3 stages
> > for things. Free but not hinted, isolated due to hinting, and free and
> > hinted. So what we would need to do is identify the size of the first
> > pool that is free and not hinted by knowing the total number of free
> > pages, and then subtract the size of the pages that are hinted and
> > still free.
> To summarize, for now, I think it makes sense to stick with the current
> approach as this way we can avoid any locking in the allocation path and
> reduce the number of hypercalls for a bunch of MAX_ORDER - 1 page.

I'm not sure what you are talking about by "avoid any locking in the
allocation path". Are you talking about the spin on idle bit, if so
then yes. However I have been testing your patches and I was correct
in the assumption that you forgot to handle the zone lock when you
were freeing __free_one_page. I just did a quick copy/paste from your
zone lock handling from the guest_free_page_hinting function into the
release_buddy_pages function and then I was able to enable multiple
CPUs without any issues.

> For the next step other than the comments received in the code and what
> I mentioned in the cover email, I would like to do the following:
> 1. Explore the watermark idea suggested by Alex and bring down memhog
> execution time if possible.

So there are a few things that are hurting us on the memhog test:
1. The current QEMU patch is only madvising 4K pages at a time, this
is disabling THP and hurts the test.

2. The fact that we madvise the pages away makes it so that we have to
fault the page back in in order to use it for the memhog test. In
order to avoid that penalty we may want to see if we can introduce
some sort of "timeout" on the pages so that we are only hinting away
old pages that have not been used for some period of time.

3. Currently we are still doing a large amount of processing in the
page free path. Ideally we should look at getting away from trying to
do so much per-cpu work and instead just have some small tasks that
put the data needed in the page, and then have a separate thread
walking the free_list checking that data, isolating the pages, hinting
them, and then returning them back to the free_list.

> 2. Benchmark hinting v/s non-hinting more extensively.
> Let me know if you have any specific suggestions in terms of the tools I
> can run to do the same. (I am planning to run atleast netperf, hackbench
> and stress for this).

So I have been running the memhog 32g test and the will-it-scale
page_fault1 test as my primary two tests for this so far.

What I have seen so far has been pretty promising. I had to do some
build fixes, fixes to QEMU to hint on the full size page instead of 4K
page, and fixes for locking so this isn't exactly your original patch
set, but with all that I am seeing data comparable to the original
patch set I had.

For memhog 32g I am seeing performance similar to a VM that was fresh
booted. I make that the comparison because you will have to take page
faults on a fresh boot as you access additional memory. However after
the first run of the runtime drops  from 22s to 20s without the
hinting enabled.

The big one that probably still needs some work will be the multi-cpu
scaling. With the per-cpu locking for the zone lock to pull pages out,
and put them back in the free list I am seeing what looks like about a
10% drop in the page_fault1 test. Here are the results as I have seen
so far on a 16 cpu 32G VM:

-- baseline --
./runtest.py page_fault1
tasks,processes,processes_idle,threads,threads_idle,linear
0,0,100,0,100,0
1,522242,93.73,514965,93.74,522242
2,929433,87.48,857280,87.50,1044484
3,1360651,81.25,1214224,81.48,1566726
4,1693709,75.01,1437156,76.33,2088968
5,2062392,68.77,1743294,70.78,2611210
6,2271363,62.54,1787238,66.75,3133452
7,2564479,56.33,1924684,61.77,3655694
8,2699897,50.09,2205783,54.28,4177936
9,2931697,43.85,2135788,50.20,4700178
10,2939384,37.63,2258725,45.04,5222420
11,3039010,31.41,2209401,41.04,5744662
12,3022976,25.19,2177655,35.68,6266904
13,3015683,18.98,2123546,31.73,6789146
14,2921798,12.77,2160489,27.30,7311388
15,2846758,6.51,1815036,17.40,7833630
16,2703146,0.36,2121018,18.21,8355872

-- modified rh patchset --
./runtest.py page_fault1
tasks,processes,processes_idle,threads,threads_idle,linear
0,0,100,0,100,0
1,527216,93.72,517459,93.70,527216
2,911239,87.48,843278,87.51,1054432
3,1295059,81.22,1193523,81.61,1581648
4,1649332,75.02,1439403,76.17,2108864
5,1985780,68.81,1745556,70.44,2636080
6,2174751,62.56,1769433,66.84,3163296
7,2433273,56.33,2121777,58.46,3690512
8,2537356,50.17,1901743,57.23,4217728
9,2737689,43.87,1859179,54.17,4744944
10,2718474,37.65,2188891,43.69,5272160
11,2743381,31.47,2205112,38.00,5799376
12,2738717,25.26,2117281,38.09,6326592
13,2643648,19.06,1887956,35.31,6853808
14,2598001,12.92,1916544,27.87,7381024
15,2498325,6.70,1992580,26.10,7908240
16,2424587,0.45,2137742,21.37,8435456

As we discussed earlier, it would probably be good to focus on only
pulling something like 4 to 8 (MAX_ORDER - 1) pages per round of
hinting. You might also look at only working one zone at a time. Then
what you could do is look at placing the pages you have already hinted
on at the tail end of the free_list and pull a new set of pages out to
hint on. You could do this all in one shot while holding the zone
lock.

