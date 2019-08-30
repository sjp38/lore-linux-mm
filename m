Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0252C3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 15:31:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D79A22CE9
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 15:31:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QjmOueDS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D79A22CE9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ED1A6B0006; Fri, 30 Aug 2019 11:31:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19F9F6B0008; Fri, 30 Aug 2019 11:31:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08C3C6B000A; Fri, 30 Aug 2019 11:31:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id DA21C6B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 11:31:51 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 59C84181AC9B4
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 15:31:51 +0000 (UTC)
X-FDA: 75879484422.08.pan25_10250a7b1551c
X-HE-Tag: pan25_10250a7b1551c
X-Filterd-Recvd-Size: 8239
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com [209.85.166.67])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 15:31:50 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id u185so11006989iod.10
        for <linux-mm@kvack.org>; Fri, 30 Aug 2019 08:31:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=THCArD2ULmPuj5QcIigwJss+eQryCDYx05ZAa455hr0=;
        b=QjmOueDSY9WLliOZMMAHB0fDBqWfU6V3IJtVE7RffkU6PaY9cNvMH/RwwajIyHploo
         GLVXcXkfYk5QmB3kgoULdqr9mePnbgwtEa78r+GduWjNms79dNF91rrCC2Cr0y8TzMWh
         sydHYrVQ5oxL5P1pySl8JkR+KqnyE4HXmYdpCTtvom59g3NPZKXEr99VrWRZeWn1U0zX
         RuZhQnoR3yX3jbIz2lFkqJgs/wVD4XJ0zf4CfLpL+ube2PMTOGmZvNbEJ2aJx1HnzMNE
         O28lQprjbGBHFTf2SFLIJjUduGK9isdAugfVDHZuwNBvwWirxWE7vrPO1bmFi54BVK73
         sXcg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=THCArD2ULmPuj5QcIigwJss+eQryCDYx05ZAa455hr0=;
        b=J6ezdfJUWxtHkWZCt8+tvYe2GQ06M01dmk1FbnuZp9jOJEPpqei4vRJ2ndkQOcwnjY
         72VsZP+kPDVtCJGEn3PQuOWqm7YRLLx5S8Hvzlfs/heef1ziyUOGY19x4TBBR3P48NkS
         YCGsNA6ru6NmHpKF12p4mdhnhPFzJEHSpMuO2Zl02Byu2PoqbU4SMljN/WHgh/xNkNPq
         Igr5O1PT/9vxvHfQoHf5bRzCVNGVDtaYznUq/6NzgyBSo6eO/4KHSSn6xNrJVBN/XIZ1
         xk39wlr8IIEuclcVZxZ3NwdVJ1DCmjI2n0INGZGcFgcDTObxJWaYnVPXU1uw3Bv4cKg0
         q7QA==
X-Gm-Message-State: APjAAAVGDi83WmraAI0APrBpSQVt6uR3UM6BotIXkvNkiF4nMiGSoCnw
	6S+mZBUxfsxNYAltLpEFO741Web38iHOA+mt9zM=
X-Google-Smtp-Source: APXvYqyY3L0jvSK597WWk0YMjyVG3pjCsfGwJ0Lib4smaB/iEuiSlgT0Vz9Ha8BL6n2yWDcUPd/WIjG+iob2z6VyRS8=
X-Received: by 2002:a02:7a52:: with SMTP id z18mr12285314jad.121.1567179110074;
 Fri, 30 Aug 2019 08:31:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190812131235.27244-1-nitesh@redhat.com> <20190812131235.27244-2-nitesh@redhat.com>
 <CAKgT0UcSabyrO=jUwq10KpJKLSuzorHDnKAGrtWVigKVgvD-6Q@mail.gmail.com> <df82bc99-a212-4f5c-dc2e-28665060acb2@redhat.com>
In-Reply-To: <df82bc99-a212-4f5c-dc2e-28665060acb2@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 30 Aug 2019 08:31:38 -0700
Message-ID: <CAKgT0Ueqok+bxANVtB1DdYorcEHN7+Grzb8MAxTzSk8uS81pRA@mail.gmail.com>
Subject: Re: [RFC][Patch v12 1/2] mm: page_reporting: core infrastructure
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	virtio-dev@lists.oasis-open.org, Paolo Bonzini <pbonzini@redhat.com>, 
	lcapitulino@redhat.com, Pankaj Gupta <pagupta@redhat.com>, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>, john.starks@microsoft.com, 
	Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, cohuck@redhat.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 30, 2019 at 8:15 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
>
> On 8/12/19 2:47 PM, Alexander Duyck wrote:
> > On Mon, Aug 12, 2019 at 6:13 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >> This patch introduces the core infrastructure for free page reporting in
> >> virtual environments. It enables the kernel to track the free pages which
> >> can be reported to its hypervisor so that the hypervisor could
> >> free and reuse that memory as per its requirement.
> >>
> >> While the pages are getting processed in the hypervisor (e.g.,
> >> via MADV_DONTNEED), the guest must not use them, otherwise, data loss
> >> would be possible. To avoid such a situation, these pages are
> >> temporarily removed from the buddy. The amount of pages removed
> >> temporarily from the buddy is governed by the backend(virtio-balloon
> >> in our case).
> >>
> >> To efficiently identify free pages that can to be reported to the
> >> hypervisor, bitmaps in a coarse granularity are used. Only fairly big
> >> chunks are reported to the hypervisor - especially, to not break up THP
> >> in the hypervisor - "MAX_ORDER - 2" on x86, and to save space. The bits
> >> in the bitmap are an indication whether a page *might* be free, not a
> >> guarantee. A new hook after buddy merging sets the bits.
> >>
> >> Bitmaps are stored per zone, protected by the zone lock. A workqueue
> >> asynchronously processes the bitmaps, trying to isolate and report pages
> >> that are still free. The backend (virtio-balloon) is responsible for
> >> reporting these batched pages to the host synchronously. Once reporting/
> >> freeing is complete, isolated pages are returned back to the buddy.
> >>
> >> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> [...]
> >> +static void scan_zone_bitmap(struct page_reporting_config *phconf,
> >> +                            struct zone *zone)
> >> +{
> >> +       unsigned long setbit;
> >> +       struct page *page;
> >> +       int count = 0;
> >> +
> >> +       sg_init_table(phconf->sg, phconf->max_pages);
> >> +
> >> +       for_each_set_bit(setbit, zone->bitmap, zone->nbits) {
> >> +               /* Process only if the page is still online */
> >> +               page = pfn_to_online_page((setbit << PAGE_REPORTING_MIN_ORDER) +
> >> +                                         zone->base_pfn);
> >> +               if (!page)
> >> +                       continue;
> >> +
> > Shouldn't you be clearing the bit and dropping the reference to
> > free_pages before you move on to the next bit? Otherwise you are going
> > to be stuck with those aren't you?
> >
> >> +               spin_lock(&zone->lock);
> >> +
> >> +               /* Ensure page is still free and can be processed */
> >> +               if (PageBuddy(page) && page_private(page) >=
> >> +                   PAGE_REPORTING_MIN_ORDER)
> >> +                       count = process_free_page(page, phconf, count);
> >> +
> >> +               spin_unlock(&zone->lock);
> > So I kind of wonder just how much overhead you are taking for bouncing
> > the zone lock once per page here. Especially since it can result in
> > you not actually making any progress since the page may have already
> > been reallocated.
> >
>
> I am wondering if there is a way to measure this overhead?
> After thinking about this, I do understand your point.
> One possible way which I can think of to address this is by having a
> page_reporting_dequeue() hook somewhere in the allocation path.

Really in order to stress this you probably need to have a lot of
CPUs, a lot of memory, and something that forces a lot of pages to get
hit such as the memory shuffling feature.

> For some reason, I am not seeing this work as I would have expected
> but I don't have solid reasoning to share yet. It could be simply
> because I am putting my hook at the wrong place. I will continue
> investigating this.
>
> In any case, I may be over complicating things here, so please let me
> if there is a better way to do this.

I have already been demonstrating the "better way" I think there is to
do this. I will push v7 of it early next week unless there is some
other feedback. By putting the bit in the page and controlling what
comes into and out of the lists it makes most of this quite a bit
easier. The only limitation is you have to modify where things get
placed in the lists so you don't create a "vapor lock" that would
stall the feed of pages into the reporting engine.

> If this overhead is not significant we can probably live with it.

You have bigger issues you still have to overcome as I recall. Didn't
you still need to sort out hotplug and a sparse map with a wide span
in a zone? Without those resolved the bitmap approach is still a no-go
regardless of performance.

- Alex

