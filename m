Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9C57C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 16:09:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60CD52080C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 16:09:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RcMVE9f4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60CD52080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD8886B0005; Tue, 25 Jun 2019 12:09:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D89CB8E0003; Tue, 25 Jun 2019 12:09:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C77DB8E0002; Tue, 25 Jun 2019 12:09:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id A6D8E6B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 12:09:16 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id j18so26957448ioj.4
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 09:09:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=k3UMAW6XTy18ywUCIThj/81Ms19rifRTEd/lQqY16ew=;
        b=foX8ntFFaLKGhUd+jqv1T+MpClFEnPmLqc86n0mePFD8wF0Zd319ZjyJbQWEr51CAz
         eltEaBV95Y0aTXKNiMbXHBlDrdpOJBqsIhYoMcmOZLkL0Md5tKRvOfr7dXZZ4jHQFCXf
         +gDwXBABhSD/T7iej9SjN2FSXe5XtlH03nzjck9Lp88WAazxk5U4IHMXMRKozvQrO8Ua
         +LsCcF+mSyHVyCBUopomNRiuw39IEAlSJ1voPGquipq+ESUiIFNuq7zVwfywkhgPf1gp
         0UvrbEiB+t6Tdk8wvptmuHkksGCIWHa8+tK5FmSuU37djKrBDZBFKt7okiICLcH2jOGN
         mykQ==
X-Gm-Message-State: APjAAAUZEEiytGh/VjRFZXVcmd8/PaB/sI50kjhIHvMklX17YQAg5/fV
	xnxis6s37s7KBfjcIs5vNryUIn2+h1cO5Yq2J+1Pnt4uabMx1HXUIGzUT9EpwYGOVcMHJ2uTJrX
	rfM3e4o/wf5dS+zJ689rwdZiT9/iuj+DCgztSY+onvYdstAz/Kj6l15q6UJRPQf2KHw==
X-Received: by 2002:a02:1607:: with SMTP id a7mr3871157jaa.123.1561478956374;
        Tue, 25 Jun 2019 09:09:16 -0700 (PDT)
X-Received: by 2002:a02:1607:: with SMTP id a7mr3871057jaa.123.1561478955337;
        Tue, 25 Jun 2019 09:09:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561478955; cv=none;
        d=google.com; s=arc-20160816;
        b=Slm20V7JCNdQd/T5hqT5wOAv6UHjaOAYUYv/K2Qs1N0mjK+jLIqrlP513wG+y0bLeq
         xKFhxmSvPwcjZpaO3Syo29TBH/M9KD4YrHjyeHhzWdJc2mCMDvUU+Ome6xTDzpMW3VXo
         wZQ58+xjXefc+gnK4OUCveJViI7LPDlFi2mS7/Gbozb4pLvudHpFWENBK5nXpyRxpamy
         m359FC52b4wWYhW+JoqcGVp02tFn7uVqNaQ/Kgh5pBYOx7pxSpO6Njok26tcrYuFIuif
         bXeSnPLfVySnUXkBRoA19L/ENg/yNn0CPIZrvNPviGishf63gYGHiKIjxlEmsmdO2hf8
         tJJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=k3UMAW6XTy18ywUCIThj/81Ms19rifRTEd/lQqY16ew=;
        b=POgVjoX0ONWH7cGA8znl/Lo1gdrdoCFM2PXawlifvpT5NFN/T7f7GnpkCYabxDUDqH
         UwcVUM8hRFDBYmFzduwvvYcredR+mEL5CTqX2LvGxWje7V9hwehV7cIGZnZAkdpYZW38
         vsLhtivgo/oORMRj+rNALoN5zXHICWQesr1IFUKGq8tGKu1NdVVVI+RglAIY/hUW14ji
         IzAmvCsm0kGgzCcggXuGZq/o5IOIA/pYvOoHFrwbQKbH2epGjRbOeGMXm7M2oMEPbwpA
         hYM8zSKyIb7M8QH1nmOxjgdbry7VOwQOBJHK2PKScbBKByK7l4E+RdSJs4VnXCdosM+n
         Bzgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RcMVE9f4;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l9sor10373566iom.67.2019.06.25.09.09.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 09:09:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RcMVE9f4;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=k3UMAW6XTy18ywUCIThj/81Ms19rifRTEd/lQqY16ew=;
        b=RcMVE9f4Bja0Quc1wT3vaYzlpnQSCmnBDIRhttxCcYMhQfFL2Si3oiW3r0hViYD5Tk
         FRaD4Hex+cjI7KWEfjC6ekEYINHz/TnrCMjgaeHvZSbCtCvRc+Xn8jB8Yi2f1Br+TYUj
         7zsFPdJWsei9CRvWVphvTkWQchIgL8I5zM8JAMEQz606ONHnrr44//hjttX/mI6cujTz
         zkbJpwqkAhH9nXJXirD36NVuyipjf/ug4oG+2V2qWien5JeV09/fVyP0fsVK8VEJDrHG
         vrJhjbU2ctmC1t/KIvpzJmdnc7kvZbbuXBdKu5+HhIiqvcj2vOQxDKr4ZoHuI6lVwA8Q
         v8ug==
X-Google-Smtp-Source: APXvYqyD+fdojUZzJs1AJNVi0qgjkM376l87i5l2KN7FZYAjv5QbKJz++V5cn1bug0htF6W8pFlVQ0Ci5zMtWUQ4iAg=
X-Received: by 2002:a6b:5106:: with SMTP id f6mr17136739iob.15.1561478954660;
 Tue, 25 Jun 2019 09:09:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190619222922.1231.27432.stgit@localhost.localdomain> <ff133df4-6291-bece-3d8d-dc3f12f398cf@redhat.com>
In-Reply-To: <ff133df4-6291-bece-3d8d-dc3f12f398cf@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 25 Jun 2019 09:09:03 -0700
Message-ID: <CAKgT0Ue4k_MHiAqMM0kyBBnPCB+828tXE2HfiZ9N1gKYayQcow@mail.gmail.com>
Subject: Re: [PATCH v1 0/6] mm / virtio: Provide support for paravirtual waste
 page treatment
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 12:42 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 20.06.19 00:32, Alexander Duyck wrote:
> > This series provides an asynchronous means of hinting to a hypervisor
> > that a guest page is no longer in use and can have the data associated
> > with it dropped. To do this I have implemented functionality that allows
> > for what I am referring to as waste page treatment.
> >
> > I have based many of the terms and functionality off of waste water
> > treatment, the idea for the similarity occurred to me after I had reached
> > the point of referring to the hints as "bubbles", as the hints used the
> > same approach as the balloon functionality but would disappear if they
> > were touched, as a result I started to think of the virtio device as an
> > aerator. The general idea with all of this is that the guest should be
> > treating the unused pages so that when they end up heading "downstream"
> > to either another guest, or back at the host they will not need to be
> > written to swap.
> >
> > When the number of "dirty" pages in a given free_area exceeds our high
> > water mark, which is currently 32, we will schedule the aeration task to
> > start going through and scrubbing the zone. While the scrubbing is taking
> > place a boundary will be defined that we use to seperate the "aerated"
> > pages from the "dirty" ones. We use the ZONE_AERATION_ACTIVE bit to flag
> > when these boundaries are in place.
>
> I still *detest* the terminology, sorry. Can't you come up with a
> simpler terminology that makes more sense in the context of operating
> systems and pages we want to hint to the hypervisor? (that is the only
> use case you are using it for so far)

I'm open to suggestions. The terminology is just what I went with as I
had gone from balloon to thinking of this as a bubble since it was a
balloon without the deflate logic. From there I got to aeration since
it is filling the buddy allocator with those bubbles.

> >
> > I am leaving a number of things hard-coded such as limiting the lowest
> > order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
> > determine what batch size it wants to allocate to process the hints.
> >
> > My primary testing has just been to verify the memory is being freed after
> > allocation by running memhog 32g in the guest and watching the total free
> > memory via /proc/meminfo on the host. With this I have verified most of
> > the memory is freed after each iteration. As far as performance I have
> > been mainly focusing on the will-it-scale/page_fault1 test running with
> > 16 vcpus. With that I have seen a less than 1% difference between the
>
> 1% throughout all benchmarks? Guess that is quite good.

That is the general idea. What I wanted to avoid was this introducing
any significant slowdown, especially in the case where we weren't
using it.

> > base kernel without these patches, with the patches and virtio-balloon
> > disabled, and with the patches and virtio-balloon enabled with hinting.
> >
> > Changes from the RFC:
> > Moved aeration requested flag out of aerator and into zone->flags.
> > Moved boundary out of free_area and into local variables for aeration.
> > Moved aeration cycle out of interrupt and into workqueue.
> > Left nr_free as total pages instead of splitting it between raw and aerated.
> > Combined size and physical address values in virtio ring into one 64b value.
> > Restructured the patch set to reduce patches from 11 to 6.
> >
>
> I'm planning to look into the details, but will be on PTO for two weeks
> starting this Saturday (and still have other things to finish first :/ ).

Thanks. No rush. I will be on PTO for the next couple of weeks myself.

> > ---
> >
> > Alexander Duyck (6):
> >       mm: Adjust shuffle code to allow for future coalescing
> >       mm: Move set/get_pcppage_migratetype to mmzone.h
> >       mm: Use zone and order instead of free area in free_list manipulators
> >       mm: Introduce "aerated" pages
> >       mm: Add logic for separating "aerated" pages from "raw" pages
> >       virtio-balloon: Add support for aerating memory via hinting
> >
> >
> >  drivers/virtio/Kconfig              |    1
> >  drivers/virtio/virtio_balloon.c     |  110 ++++++++++++++
> >  include/linux/memory_aeration.h     |  118 +++++++++++++++
> >  include/linux/mmzone.h              |  113 +++++++++------
> >  include/linux/page-flags.h          |    8 +
> >  include/uapi/linux/virtio_balloon.h |    1
> >  mm/Kconfig                          |    5 +
> >  mm/Makefile                         |    1
> >  mm/aeration.c                       |  270 +++++++++++++++++++++++++++++++++++
> >  mm/page_alloc.c                     |  203 ++++++++++++++++++--------
> >  mm/shuffle.c                        |   24 ---
> >  mm/shuffle.h                        |   35 +++++
> >  12 files changed, 753 insertions(+), 136 deletions(-)
> >  create mode 100644 include/linux/memory_aeration.h
> >  create mode 100644 mm/aeration.c
>
> Compared to
>
>  17 files changed, 838 insertions(+), 86 deletions(-)
>  create mode 100644 include/linux/memory_aeration.h
>  create mode 100644 mm/aeration.c
>
> this looks like a good improvement :)

Thanks.

- Alex

