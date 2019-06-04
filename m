Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69E56C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 17:12:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21BF52075B
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 17:12:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Bd7V+auq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21BF52075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C8B26B0272; Tue,  4 Jun 2019 13:12:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 951F56B0273; Tue,  4 Jun 2019 13:12:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8415B6B0274; Tue,  4 Jun 2019 13:12:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 632136B0272
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 13:12:20 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id m20so576255itn.3
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 10:12:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YwvRTSi8hPGYNKJsDR2mQt7/vaWadpcHt5lEeh5TQj0=;
        b=Jxf5VN1zcsjLEQu3LjuSK7fa+vCoCAsZ7614ok5rbuOolDKFhcINN6B1Z6v6wqbjrU
         k3rm8zK3qGWQyhpEVLaoS7Z1KQKxQhUyWB9UCi11b3bdI3ms23xF+n7Q9g1jtlMfbH2L
         hcoWeJw7yn8LtYbEbG6xHJVGTbUYTba/PQ2/Ijc2U4Zzj1uGFb2YN7jvobXnN5DA5zcJ
         xVlAoqYp894LCb5mHs5rXBKnQu/4mAx4DBQsOa1+JKA2cXY0tbqYcWEH2X2moLXu8Q0m
         8fkQzrmGhaCCAvRVXO5W4PiYlkEj48ni/cM0DuQZ1/zsIxMXP5Te/0g7oMZCoUj2UpiT
         HTtg==
X-Gm-Message-State: APjAAAVsFO2IcRBbWSwvWBXw0b8pIMHzHlSkkjDUs33Jj20lR+lIvRL4
	Ucn2QqLkeKnxN46CdI4sT6qTIARGGEEAFPfapncx/i56qw0nnc695l9ZOF+qp+rFpSsvOo0+ajS
	0PkXX355OJpckbtTCweeOkh0paHwTywmlDJwkzMd6fdJuajoy1Q9vzjfvt5CtnhouRQ==
X-Received: by 2002:a02:81:: with SMTP id 123mr3542925jaa.105.1559668340163;
        Tue, 04 Jun 2019 10:12:20 -0700 (PDT)
X-Received: by 2002:a02:81:: with SMTP id 123mr3542850jaa.105.1559668339285;
        Tue, 04 Jun 2019 10:12:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559668339; cv=none;
        d=google.com; s=arc-20160816;
        b=m3noZDeUC9CjN++DMCehpbsZRqrRVLPUgXsb0KnoP/MHkgMjLko1SqGIINu4fNphEi
         vcqDn2tQDa54NYgaCj56Na+MVVDiwvi7BqSrvaBEop9wo5KdYYq2J58ljuSCN2I2oQK6
         Lj1QIGWlheitt8gtaBo9zczD545hKg843grFyPelJMAYGBWNFCF79RWysA/7R2pVrCtK
         Zcd6bzdqzVC2GZabdgxdH5rTdwPW8Ks2AkkBX7TLlM+njIgJwsFwxBbD9aF6/uKL/ZzD
         7mMjoXuhP4rsqwhiUWiDEzlH8RF1KST88jUPJf3Js5D92AyfYV6CNZhIwx23lqIUHG3c
         gINg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YwvRTSi8hPGYNKJsDR2mQt7/vaWadpcHt5lEeh5TQj0=;
        b=Zj/qATPFbyD7Cxq2V/IzC29NpjaazGSB1FUayfCaIqRv6o9Z+ymHxMwIuetZfzZGNm
         QhXBKsjfmupewihlHUsTIS+cxsgc3yTH8BJ0YbzP3uSI1j9ptJ8M99VOTiU3nAfDw1LL
         K5MpYayfgT+qsFitI99JwHwbU/mGiiCxYxOa4xAxPh7cobD5sA/QdhoJbg9/10xxMaQm
         yh4ybZp2+NIO9BBGWnJw8OTiULexO8yYdesvaSIMKQ6QSbZQjTSPzwz3Sngpn40p6SGA
         RrYSMfmiXYOVvIQ9sXEHzJvpKQ+kr2xHktqyIzh7FPLFR9S3zmzRqeOPOWbZjrkIJPF9
         obag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Bd7V+auq;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21sor12465391jan.8.2019.06.04.10.12.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 10:12:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Bd7V+auq;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YwvRTSi8hPGYNKJsDR2mQt7/vaWadpcHt5lEeh5TQj0=;
        b=Bd7V+auq6f1XOlBC2pUbLKqKr37pQFOUTGlbFWLySuV7WdFk20+wWfgl3DexqyqwRQ
         XTDFAAqxb2uedga0O//1YKG7BxO++EqRAdTJdR0Y1Yc8JRNi/Gqk2hlMF6cWkPDGYb/n
         BZpijgpA88Vzp+0/F3BHuGiSX9COx3eW/7j4hyowUM93hYHLDnWbY+QOp/BWgek0nl8y
         TIk2/Dhr7rBv7tEKAm/Iew4qO46003bLBEdENnaXALWzuCyK5YYffZLrHlYdQBCO/qh0
         qpQIUYM79bGjKfEXOYm2wOIuuU2nJ1TwLvYOeKwhNpk4X9fSBCJF23V0T6hj88q4c0gU
         X3mQ==
X-Google-Smtp-Source: APXvYqzDktx7jgwD6BJgywS6VvFnx4Vw5PiOeWLjzlixLk9bShnuYNP9pOlCXdlEUtnAFTWLZjmGg9tX/MfqEkD4oI4=
X-Received: by 2002:a02:b914:: with SMTP id v20mr2116128jan.83.1559668338874;
 Tue, 04 Jun 2019 10:12:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190603170306.49099-1-nitesh@redhat.com> <20190603170306.49099-2-nitesh@redhat.com>
 <CAKgT0Udnc_cmgBLFEZ5udexsc1cfjX1rJR3qQFOW-7bfuFh6gQ@mail.gmail.com>
 <4cdfee20-126e-bc28-cf1c-2cfd484ca28e@redhat.com> <CAKgT0Ud6uKpcj9HFHYOThCY=0_P0=quBLbsDR7uUMdbwcYeSTw@mail.gmail.com>
 <09e6caea-7000-b3e4-d297-df6bea78e127@redhat.com> <CAKgT0UeMpcckGpT6OnC2kqgtyT2p9bvNgE2C0eqW1GOJTU-DHA@mail.gmail.com>
 <13b96507-6347-1702-7822-6efb0f1bbf20@redhat.com>
In-Reply-To: <13b96507-6347-1702-7822-6efb0f1bbf20@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 4 Jun 2019 10:12:07 -0700
Message-ID: <CAKgT0UfEevMZu_1B0Og5QdOjj0R2PKJyo8msaHfouaL_oNegTw@mail.gmail.com>
Subject: Re: [RFC][Patch v10 1/2] mm: page_hinting: core infrastructure
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 9:42 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
>
> On 6/4/19 12:25 PM, Alexander Duyck wrote:
> > On Tue, Jun 4, 2019 at 9:08 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>
> >> On 6/4/19 11:14 AM, Alexander Duyck wrote:
> >>> On Tue, Jun 4, 2019 at 5:55 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>>> On 6/3/19 3:04 PM, Alexander Duyck wrote:
> >>>>> On Mon, Jun 3, 2019 at 10:04 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>>>>> This patch introduces the core infrastructure for free page hinting in
> >>>>>> virtual environments. It enables the kernel to track the free pages which
> >>>>>> can be reported to its hypervisor so that the hypervisor could
> >>>>>> free and reuse that memory as per its requirement.
> >>>>>>
> >>>>>> While the pages are getting processed in the hypervisor (e.g.,
> >>>>>> via MADV_FREE), the guest must not use them, otherwise, data loss
> >>>>>> would be possible. To avoid such a situation, these pages are
> >>>>>> temporarily removed from the buddy. The amount of pages removed
> >>>>>> temporarily from the buddy is governed by the backend(virtio-balloon
> >>>>>> in our case).
> >>>>>>
> >>>>>> To efficiently identify free pages that can to be hinted to the
> >>>>>> hypervisor, bitmaps in a coarse granularity are used. Only fairly big
> >>>>>> chunks are reported to the hypervisor - especially, to not break up THP
> >>>>>> in the hypervisor - "MAX_ORDER - 2" on x86, and to save space. The bits
> >>>>>> in the bitmap are an indication whether a page *might* be free, not a
> >>>>>> guarantee. A new hook after buddy merging sets the bits.
> >>>>>>
> >>>>>> Bitmaps are stored per zone, protected by the zone lock. A workqueue
> >>>>>> asynchronously processes the bitmaps, trying to isolate and report pages
> >>>>>> that are still free. The backend (virtio-balloon) is responsible for
> >>>>>> reporting these batched pages to the host synchronously. Once reporting/
> >>>>>> freeing is complete, isolated pages are returned back to the buddy.
> >>>>>>
> >>>>>> There are still various things to look into (e.g., memory hotplug, more
> >>>>>> efficient locking, possible races when disabling).
> >>>>>>
> >>>>>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> >>>>> So one thing I had thought about, that I don't believe that has been
> >>>>> addressed in your solution, is to determine a means to guarantee
> >>>>> forward progress. If you have a noisy thread that is allocating and
> >>>>> freeing some block of memory repeatedly you will be stuck processing
> >>>>> that and cannot get to the other work. Specifically if you have a zone
> >>>>> where somebody is just cycling the number of pages needed to fill your
> >>>>> hinting queue how do you get around it and get to the data that is
> >>>>> actually code instead of getting stuck processing the noise?
> >>>> It should not matter. As every time the memory threshold is met, entire
> >>>> bitmap
> >>>> is scanned and not just a chunk of memory for possible isolation. This
> >>>> will guarantee
> >>>> forward progress.
> >>> So I think there may still be some issues. I see how you go from the
> >>> start to the end, but how to you loop back to the start again as pages
> >>> are added? The init_hinting_wq doesn't seem to have a way to get back
> >>> to the start again if there is still work to do after you have
> >>> completed your pass without queue_work_on firing off another thread.
> >>>
> >> That will be taken care as the part of a new job, which will be
> >> en-queued as soon
> >> as the free memory count for the respective zone will reach the threshold.
> > So does that mean that you have multiple threads all calling
> > queue_work_on until you get below the threshold?
> Every time a page of order MAX_ORDER - 2 is added to the buddy, free
> memory count will be incremented if the bit is not already set and its
> value will be checked against the threshold.
> >  If so it seems like
> > that would get expensive since that is an atomic test and set
> > operation that would be hammered until you get below that threshold.
>
> Not sure if I understood "until you get below that threshold".
> Can you please explain?
> test_and_set_bit() will be called every time a page with MAX_ORDER -2
> order is added to the buddy. (Not already hinted)

I had overlooked the other paths that are already making use of the
test_and_set_bit(). What I was getting at specifically is that the
WORK_PENDING bit in the work struct is going to be getting hit every
time you add a new page. So it is adding yet another atomic operation
in addition to the increment and test_and_set_bit() that you were
already doing.

Generally you may want to look at trying to reduce how often you are
having to perform these atomic operations. So for example one thing
you could do is use something like an atomic_read before you do your
atomic_inc to determine if you are transitioning to a state where you
were below, and now you are above the threshold. Doing something like
that could save you on the number of calls you are making and save
some significant CPU cycles.

