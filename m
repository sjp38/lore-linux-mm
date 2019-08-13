Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74657C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 23:14:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 290C420663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 23:14:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YCRnu82X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 290C420663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3BDF6B000D; Tue, 13 Aug 2019 19:14:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AECF46B000E; Tue, 13 Aug 2019 19:14:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DAB26B0010; Tue, 13 Aug 2019 19:14:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0249.hostedemail.com [216.40.44.249])
	by kanga.kvack.org (Postfix) with ESMTP id 763886B000D
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 19:14:49 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 27F3F127B
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 23:14:49 +0000 (UTC)
X-FDA: 75818961498.16.game22_ce72b2bc124d
X-HE-Tag: game22_ce72b2bc124d
X-Filterd-Recvd-Size: 6226
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com [209.85.210.65])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 23:14:48 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id j7so33320337ota.9
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:14:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JfCDYzsbmylRyo21gErMd6dmJhyO/WKByIVYuR2+KCQ=;
        b=YCRnu82XB51HlJE2bJ2ABN473mPpLvpS1+D+gsZKtfSqkAJWl3J2febSoofC9HVlXv
         4UpKKuTsjLtc1nCxNACdSMt3GbSMoAADzqfWfvprYprmroYb2/7aES+50BLjnvqQfy84
         tIvgdL3DxiC5tA9xy1j6FgdZO36ONJYh3B0dzA6NruPx7pfaxtmyeYfORBHPPG5qaY7Y
         V6FScNDv12Fk33JzrJibueWFzllWA54+7utXKTBA7N9RDlGjTyJv+y/gRE3jLlJ2bAsj
         UoBEEIKUHtdsSUrYob4u0uXuKBOduX1bCx+nWrKKzk+d/qLtb/KPiIHuG5azLupljFK5
         YB2w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=JfCDYzsbmylRyo21gErMd6dmJhyO/WKByIVYuR2+KCQ=;
        b=Iy85UHprKjeFXQRB6j8O3/vUeif0xLkquVnBMmZygJgW+ObBPtkeOXywac91kt7Dwh
         KCybGpR7Az+wCMaH77Kz4wZIgKONFdEY5FzfXF7K7TV5TPLKawXPXSoyGFrCBuz7cEHi
         rJeJFPMxPG9zUT9OgZr9JWRywM4QDTHWzLX3/5XTDg58UHg8KhpEh4KJlyUNdufR8Vth
         poPWIj9V7LDnoT2zzqxB1SBQhPnYpy/q6Id4xPd2XZ8immRcYJSwFj9OaIw5Cqxucb4n
         /NqDe+dJnilINPEzhDucpYIeO+HQPfJYpzyfGICZHEU0qRMgQDyU50H9f0Kood3mQUyR
         /Piw==
X-Gm-Message-State: APjAAAU+xglvZKR9v52jmTXiAnCix2BfyHumAgCOkGhTgmdO23eth+PP
	L+GhNGivSBGJALcVHLnKZlypqph5n1F7ZuS2TYc=
X-Google-Smtp-Source: APXvYqwLI2Fib9qI+Djp/FJahaxKBV2uh7K8EoSHkO2am5+Zd+BprsaBzWmlkQ135bmDf66SvtJqCocH0IsUZ14QZ88=
X-Received: by 2002:a5e:8c11:: with SMTP id n17mr5577226ioj.64.1565738087631;
 Tue, 13 Aug 2019 16:14:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190812131235.27244-1-nitesh@redhat.com> <20190812131235.27244-2-nitesh@redhat.com>
 <CAKgT0UcSabyrO=jUwq10KpJKLSuzorHDnKAGrtWVigKVgvD-6Q@mail.gmail.com>
 <ca362045-9668-18ff-39b0-de91fa72e73c@redhat.com> <d39504c9-93bd-b8f7-e119-84baac5a42d4@redhat.com>
 <32f61f87-6205-5001-866c-a84e20fc9d85@redhat.com>
In-Reply-To: <32f61f87-6205-5001-866c-a84e20fc9d85@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 13 Aug 2019 16:14:36 -0700
Message-ID: <CAKgT0UfaaHrEaS2wsbdTuzCdCtSrM4Tx79w=dP8HPEnq+T7rtQ@mail.gmail.com>
Subject: Re: [RFC][Patch v12 1/2] mm: page_reporting: core infrastructure
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
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

On Tue, Aug 13, 2019 at 3:34 AM David Hildenbrand <david@redhat.com> wrote:
>
> >>>> +static int process_free_page(struct page *page,
> >>>> +                            struct page_reporting_config *phconf, int count)
> >>>> +{
> >>>> +       int mt, order, ret = 0;
> >>>> +
> >>>> +       mt = get_pageblock_migratetype(page);
> >>>> +       order = page_private(page);
> >>>> +       ret = __isolate_free_page(page, order);
> >>>> +
> >> I just started looking into the wonderful world of
> >> isolation/compaction/migration.
> >>
> >> I don't think saving/restoring the migratetype is correct here. AFAIK,
> >> MOVABLE/UNMOVABLE/RECLAIMABLE is just a hint, doesn't mean that e.g.,
> >> movable pages and up in UNMOVABLE or ordinary kernel allocations on
> >> MOVABLE. So that shouldn't be an issue - I guess.
> >>
> >> 1. You should never allocate something that is no
> >> MOVABLE/UNMOVABLE/RECLAIMABLE. Especially not, if you have ISOLATE or
> >> CMA here. There should at least be a !is_migrate_isolate_page() check
> >> somewhere
> >>
> >> 2. set_migratetype_isolate() takes the zone lock, so to avoid racing
> >> with isolation code, you have to hold the zone lock. Your code seems to
> >> do that, so at least you cannot race against isolation.
> >>
> >> 3. You could end up temporarily allocating something in the
> >> ZONE_MOVABLE. The pages you allocate are, however, not movable. There
> >> would have to be a way to make alloc_contig_range()/offlining code
> >> properly wait until the pages have been processed. Not sure about the
> >> real implications, though - too many details in the code (I wonder if
> >> Alex' series has a way of dealing with that)
> >>
> >> When you restore the migratetype, you could suddenly overwrite e.g.,
> >> ISOLATE, which feels wrong.
> >
> >
> > I was triggering an occasional CPU stall bug earlier, with saving and restoring
> > the migratetype I was able to fix it.
> > But I will further look into this to figure out if it is really required.
> >
>
> You should especially look into handling isolated/cma pages. Maybe that
> was the original issue. Alex seems to have added that in his latest
> series (skipping isolated/cma pageblocks completely) as well.

So as far as skipping isolated pageblocks, I get the reason for
skipping isolated, but why would we need to skip CMA? I had made the
change I did based on comments you had made earlier. But while working
on some of the changes to address isolation better and looking over
several spots in the code it seems like CMA is already being used as
an allocation fallback for MIGRATE_MOVABLE. If that is the case
wouldn't it make sense to allow pulling pages and reporting them while
they are in the free_list?

