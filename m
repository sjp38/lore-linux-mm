Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C53F4C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:25:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F02520717
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:25:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W/L7XlWa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F02520717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04FB96B0010; Tue,  4 Jun 2019 12:25:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 000286B0269; Tue,  4 Jun 2019 12:25:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E58DD6B026B; Tue,  4 Jun 2019 12:25:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4FEE6B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:25:29 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id m20so459834itn.3
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:25:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=keUx6OuTtnNnS8af2D8MRcezvwV9OMJ0K5kA2b/Onj8=;
        b=gQNk0RCR67/m5LgzoXOi3gBLrejLEvpcUVuBmp2QjLfiUzSjO3CJLCbomUX/4ZqHvW
         G8wDGJTE5SO9SI2DrdgSzTjjQmKRlXZpPBwIYZc3DkS6njD0taITsZhBw0vPSBRw9aSY
         SpZXZRC9bmv7xBOlFUipoDZX1aqM+m9DaUDOhp6QumjD5D9WF4VGECepWWXfnsAu0UN1
         kF4lp6YLpn3WvHexYpC/HLp3KkRBEjv+egENGHn599wjOumx6qoF81I/q5yP+M4Y2+De
         OQMSeTbH+SDbsbqM/TjFiWp+8Rpz63s7s/HWqPQ4ErzluPsENf4qHQOobqvAi9/OVqlX
         t1QQ==
X-Gm-Message-State: APjAAAVIHLItkKAn81o6hhh3+a2442F+1N2BqF8QaRIaxmHtP7NuMtzm
	cHhquYWzOgKrmGSbK6964N+eVR1on2MMpvQz6Mb/6KuMoJrDdGp14AAjSpneDkDsUnzj7xk/ePO
	WPiSbyUy0bzCLCLYe6B+3mgHkYd8o2BmnzBXxlMsTOHSEKHoxiXrXjevAjsyAtqzcPw==
X-Received: by 2002:a6b:c9c1:: with SMTP id z184mr17540118iof.74.1559665529525;
        Tue, 04 Jun 2019 09:25:29 -0700 (PDT)
X-Received: by 2002:a6b:c9c1:: with SMTP id z184mr17540082iof.74.1559665528662;
        Tue, 04 Jun 2019 09:25:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559665528; cv=none;
        d=google.com; s=arc-20160816;
        b=VMMyGR1f4/VOjVwp7W42rleXBPtmGykJ8lZTj4T4COlRSF/i7ajTdqm7fq+iaCFl8y
         Fi413kQIjhadycA7JJWTqgHI9usUe8O3PiZT16txuNJFLJyjFHc8Rqr7NB/CAzZhUFM3
         /KHhFaxEaDh1ZEEEcZQUvGrfgf5p5oWbn+Tvtc3F5zK2F7U3DTuuYk5zo74v+nm5RA5u
         GgDRCdlnyd4/sENeiNtg3lEaEow4ypkMijSo2QxpS6dMgOkoFpjm7RPp9GoOesLUYONR
         3TWKGsd8SDTwoN//m+4Oa+iRVgOsiO+/Tb3KuoDIAh7sWBt6sFEHhc+C7pQQK7psBJxX
         IlVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=keUx6OuTtnNnS8af2D8MRcezvwV9OMJ0K5kA2b/Onj8=;
        b=MKUJ4IAOwWswL/sRJQIrQu7HVefFWYcEBaKSUUT4zbxs1RMGC0NUQOiIDHmeOY72u7
         iQKok0lDrM9ohHLPsbS2xtLX6XRP/pi5kwvo+kQGSgAaPrDT++zQ6DSukDW2KptpETgz
         1JhK1XSSO7vUiTq8H7JKrjqblYNWZxXnUnzYtLqKgxIH2YRwHVuhIoHEGq2GmfmazQ9u
         b19oe5hvnJ5q092o3OTpvBqrqseMyqmaWBN+4mgSpgid1ZyiaD7yR/2BcLMUKCmFJADS
         xP/v8CQCpAcspClK/hWj6Yh3wjBWveoSZ/tUDd0h1FB2GiiehsYDjj+zKCNLs4FGl7s6
         oDpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="W/L7XlWa";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3sor12322423jaj.7.2019.06.04.09.25.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 09:25:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="W/L7XlWa";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=keUx6OuTtnNnS8af2D8MRcezvwV9OMJ0K5kA2b/Onj8=;
        b=W/L7XlWaFAFC25Fsz4CXjMTrwc8PsTmaQ8HGbUAYsAo60RiR9fODX6dyVe9/QY2ZPe
         kcWVcaBcvoM3Te+G8UuxrDWK305KGBkb1QlFNgoTOUwmB+ySljpLY/LNOkHUVfyNof5Y
         RWu7BSCU1KTy8xhog0NHEaML4VIAPY9wEs13EyeiRTVcW4HQ+i43ncoyTxb18LtXyoba
         s3ClM75/YGscb0IR39VRwOcvsCp/wc+Cl4w4GI4e1I/Xc6JGJtjCga77WcgnCTSYxXi3
         xSGoOldTC1VSI6zCOg8zXg51veJ3U2NQOIATn6cfOFQzWuzsWsENpwwbGLogs8uow04Y
         Bt4A==
X-Google-Smtp-Source: APXvYqx/4rCisoqpGnzzw0zsbZQJzp6XnK7vklgy6SJ5670sERpis86AGb6uijJLfZA5p9whZRyv+dcYdZCQul/rIyg=
X-Received: by 2002:a02:5b05:: with SMTP id g5mr20735653jab.114.1559665528083;
 Tue, 04 Jun 2019 09:25:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190603170306.49099-1-nitesh@redhat.com> <20190603170306.49099-2-nitesh@redhat.com>
 <CAKgT0Udnc_cmgBLFEZ5udexsc1cfjX1rJR3qQFOW-7bfuFh6gQ@mail.gmail.com>
 <4cdfee20-126e-bc28-cf1c-2cfd484ca28e@redhat.com> <CAKgT0Ud6uKpcj9HFHYOThCY=0_P0=quBLbsDR7uUMdbwcYeSTw@mail.gmail.com>
 <09e6caea-7000-b3e4-d297-df6bea78e127@redhat.com>
In-Reply-To: <09e6caea-7000-b3e4-d297-df6bea78e127@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 4 Jun 2019 09:25:16 -0700
Message-ID: <CAKgT0UeMpcckGpT6OnC2kqgtyT2p9bvNgE2C0eqW1GOJTU-DHA@mail.gmail.com>
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

On Tue, Jun 4, 2019 at 9:08 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
>
> On 6/4/19 11:14 AM, Alexander Duyck wrote:
> > On Tue, Jun 4, 2019 at 5:55 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>
> >> On 6/3/19 3:04 PM, Alexander Duyck wrote:
> >>> On Mon, Jun 3, 2019 at 10:04 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
> >>>> This patch introduces the core infrastructure for free page hinting in
> >>>> virtual environments. It enables the kernel to track the free pages which
> >>>> can be reported to its hypervisor so that the hypervisor could
> >>>> free and reuse that memory as per its requirement.
> >>>>
> >>>> While the pages are getting processed in the hypervisor (e.g.,
> >>>> via MADV_FREE), the guest must not use them, otherwise, data loss
> >>>> would be possible. To avoid such a situation, these pages are
> >>>> temporarily removed from the buddy. The amount of pages removed
> >>>> temporarily from the buddy is governed by the backend(virtio-balloon
> >>>> in our case).
> >>>>
> >>>> To efficiently identify free pages that can to be hinted to the
> >>>> hypervisor, bitmaps in a coarse granularity are used. Only fairly big
> >>>> chunks are reported to the hypervisor - especially, to not break up THP
> >>>> in the hypervisor - "MAX_ORDER - 2" on x86, and to save space. The bits
> >>>> in the bitmap are an indication whether a page *might* be free, not a
> >>>> guarantee. A new hook after buddy merging sets the bits.
> >>>>
> >>>> Bitmaps are stored per zone, protected by the zone lock. A workqueue
> >>>> asynchronously processes the bitmaps, trying to isolate and report pages
> >>>> that are still free. The backend (virtio-balloon) is responsible for
> >>>> reporting these batched pages to the host synchronously. Once reporting/
> >>>> freeing is complete, isolated pages are returned back to the buddy.
> >>>>
> >>>> There are still various things to look into (e.g., memory hotplug, more
> >>>> efficient locking, possible races when disabling).
> >>>>
> >>>> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> >>> So one thing I had thought about, that I don't believe that has been
> >>> addressed in your solution, is to determine a means to guarantee
> >>> forward progress. If you have a noisy thread that is allocating and
> >>> freeing some block of memory repeatedly you will be stuck processing
> >>> that and cannot get to the other work. Specifically if you have a zone
> >>> where somebody is just cycling the number of pages needed to fill your
> >>> hinting queue how do you get around it and get to the data that is
> >>> actually code instead of getting stuck processing the noise?
> >> It should not matter. As every time the memory threshold is met, entire
> >> bitmap
> >> is scanned and not just a chunk of memory for possible isolation. This
> >> will guarantee
> >> forward progress.
> > So I think there may still be some issues. I see how you go from the
> > start to the end, but how to you loop back to the start again as pages
> > are added? The init_hinting_wq doesn't seem to have a way to get back
> > to the start again if there is still work to do after you have
> > completed your pass without queue_work_on firing off another thread.
> >
> That will be taken care as the part of a new job, which will be
> en-queued as soon
> as the free memory count for the respective zone will reach the threshold.

So does that mean that you have multiple threads all calling
queue_work_on until you get below the threshold? If so it seems like
that would get expensive since that is an atomic test and set
operation that would be hammered until you get below that threshold.

