Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E9FFC76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:29:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 338D021019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:29:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y/qJ3wC7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 338D021019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDF596B0007; Thu, 18 Jul 2019 16:29:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B903C8E0003; Thu, 18 Jul 2019 16:29:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A593C8E0001; Thu, 18 Jul 2019 16:29:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8686C6B0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:29:27 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x11so21104944qto.23
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:29:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JUUHjmg0ZJlEMX+5AtmRzyp8ZylGGNhXn5v6WzeqTo0=;
        b=SmM9jHw39YJ77DjqwmcmEFmuGewRLCS1zSGPTXsQQRG+S7VNHiiV+1AdvSK95hgj1v
         kMLy7p2V1Xy9PHvM1pSz0H82bC9za/kMvrLrHKj5V/+Zllfk5jjlJLEXBTFcX9j/gVU3
         HC8Xm9pPbUUr6uEVmMuZbmtsFGim9z+0E4b6e8enab2dUUoZeDOthFz9ismn6PRdmg3S
         OoAPHq4Jdyi4ZXayEzgjaR3vSyuaUedrPcQMM6LNaaWdSxfDOFTocZC4ctdrH7d+vz+C
         wIs6pXLin1v2pg86kZ8XGBml2MK3gN7kA+aVPmsiXrvoP2nX2pqtjOTceSGkBbZcQMTX
         5EsQ==
X-Gm-Message-State: APjAAAUvrmCi5ByttMB/JYpyV6xsIJWTkCgFEubMI+4W0m2wGCA6V/Og
	pp2c8TLzHo6w8vsA4dn6Pogdvb/5qESXEZu9FGEbOnmz8TteTFaYowanQByjP/tEa1EzPH6tlWn
	Rz7EJfqOo3LPKFX1Qtif6T1Ss3fT+7g3BwNZ9iLCiWOqDXPEYFOPMa6t0WVNVH1E2NQ==
X-Received: by 2002:ac8:32ec:: with SMTP id a41mr34560517qtb.375.1563481767267;
        Thu, 18 Jul 2019 13:29:27 -0700 (PDT)
X-Received: by 2002:ac8:32ec:: with SMTP id a41mr34560501qtb.375.1563481766654;
        Thu, 18 Jul 2019 13:29:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563481766; cv=none;
        d=google.com; s=arc-20160816;
        b=aFhqOtw3n2SPatkYE56HS86zshnv561FQDd5xBBOVvBRwKB9rMXcUb5orx68NKFtny
         BpARqdgxm0xp5cHV/NgZ2QZwEg1xf9ZTyxmPV71rkWlOGZ9J62/kzaI1sIKw7cEtjL/i
         evtcr9jm8Bm/6T3d27PZdfW+VcNMM4BLwf/qDr7uODh0FRgfkp3qV3CDDN06GP79e1Rf
         WvK2IawDRS1Hn4LVXm7ZZThNOdpUTam4IoGW7TU2vBIH8QYUWH/u+23bWewNkMkVs5eT
         vYquyTxHGqtrHRHbepqn+CeOYE/4YffG9awD5npenhSgmnb5r+S9LP+C0ONrx/CygEci
         TzIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JUUHjmg0ZJlEMX+5AtmRzyp8ZylGGNhXn5v6WzeqTo0=;
        b=QTajZ298AujrogYMM+fWUP3Kdo9qi/A6/EOgNoOsTwcS8QmVXRXwtgMJo0yRH1Dmyo
         igCH+sYm4N3TEbfnxtT523ckZbsEMTjRvFLF/D3alxDv0MD5q5IP2BcYhxj7rsTUn/Qn
         sYYyaA7Fgxd/74O6j0jjiHzunZX3KtZ3/quc40VyDm7xpNnbIv0z7EwG7D29BoBTf0zd
         ZQ7ngqbCuYXxxoyS91PRzkbLiqQxOoyP7BtKOWgavYfTe9MJc09BkIKzHyWv42T+5KS9
         zlr0XcgMmZvpyDs+FlHD6kOEoenHk3q8NVZdC6V+7E2ym3H9bWleQmgfZlMoEmt9FBQP
         bhbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Y/qJ3wC7";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e50sor39091540qte.22.2019.07.18.13.29.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 13:29:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Y/qJ3wC7";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JUUHjmg0ZJlEMX+5AtmRzyp8ZylGGNhXn5v6WzeqTo0=;
        b=Y/qJ3wC7lCk9kEZssbkBI/gkQdhuwiy4ifGVRGGiJNvAFxFoCzoCRiVh2OqmkH3nj4
         TjO+9Grh7N49eh/cS4HANTtHCHTBvPydFBIxFWF/UCXTmseqaCEPkadsRMS1lvMwpuKR
         fKfL+c6zkn5Da3l8N/CT17I7zjp8C3+fHViFGjExp8txHDlaq8WaMh3Zw/RvLltA1DNy
         TrfIsCYu/LMC9GO8tvwUbbbrwM1riNmyY0hrBPZYor2C6MBFCZeSb9OPRIe1OS+1zzmv
         GCS80WZE8idvO30m5HjU+OFSnWdyMWVrfYjuCvhqSfSqRPS+HZwa3l6eFd1Ish2WBU5H
         iscg==
X-Google-Smtp-Source: APXvYqwl+bEO1h8j2u/h/gYaq6zlsr1eertU95oqDRxjqkM7ku54EZON6JrY0jQ1geCz48TkU7laYiYzVhvnq8OjPuQ=
X-Received: by 2002:ac8:2f43:: with SMTP id k3mr34539909qta.179.1563481766276;
 Thu, 18 Jul 2019 13:29:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190716055017-mutt-send-email-mst@kernel.org>
 <CAKgT0Uc-2k9o7pjtf-GFAgr83c7RM-RTJ8-OrEzFv92uz+MTDw@mail.gmail.com>
 <20190716115535-mutt-send-email-mst@kernel.org> <CAKgT0Ud47-cWu9VnAAD_Q2Fjia5gaWCz_L9HUF6PBhbugv6tCQ@mail.gmail.com>
 <20190716125845-mutt-send-email-mst@kernel.org> <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
 <20190717055804-mutt-send-email-mst@kernel.org> <CAKgT0Uf4iJxEx+3q_Vo9L1QPuv9PhZUv1=M9UCsn6_qs7rG4aw@mail.gmail.com>
 <20190718003211-mutt-send-email-mst@kernel.org> <CAKgT0UfQ3dtfjjm8wnNxX1+Azav6ws9zemH6KYc7RuyvyFo3fQ@mail.gmail.com>
 <20190718113548-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190718113548-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 18 Jul 2019 13:29:14 -0700
Message-ID: <CAKgT0UeRy2eHKnz4CorefBAG8ro+3h4oFX+z1JY2qRm17fcV8w@mail.gmail.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
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

On Thu, Jul 18, 2019 at 9:07 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Thu, Jul 18, 2019 at 08:34:37AM -0700, Alexander Duyck wrote:
> > On Wed, Jul 17, 2019 at 10:14 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> > >
> > > On Wed, Jul 17, 2019 at 09:43:52AM -0700, Alexander Duyck wrote:
> > > > On Wed, Jul 17, 2019 at 3:28 AM Michael S. Tsirkin <mst@redhat.com> wrote:
> > > > >
> > > > > On Tue, Jul 16, 2019 at 02:06:59PM -0700, Alexander Duyck wrote:
> > > > > > On Tue, Jul 16, 2019 at 10:41 AM Michael S. Tsirkin <mst@redhat.com> wrote:
> > > > > >
> > > > > > <snip>
> > > > > >
> > > > > > > > > This is what I am saying. Having watched that patchset being developed,
> > > > > > > > > I think that's simply because processing blocks required mm core
> > > > > > > > > changes, which Wei was not up to pushing through.
> > > > > > > > >
> > > > > > > > >
> > > > > > > > > If we did
> > > > > > > > >
> > > > > > > > >         while (1) {
> > > > > > > > >                 alloc_pages
> > > > > > > > >                 add_buf
> > > > > > > > >                 get_buf
> > > > > > > > >                 free_pages
> > > > > > > > >         }
> > > > > > > > >
> > > > > > > > > We'd end up passing the same page to balloon again and again.
> > > > > > > > >
> > > > > > > > > So we end up reserving lots of memory with alloc_pages instead.
> > > > > > > > >
> > > > > > > > > What I am saying is that now that you are developing
> > > > > > > > > infrastructure to iterate over free pages,
> > > > > > > > > FREE_PAGE_HINT should be able to use it too.
> > > > > > > > > Whether that's possible might be a good indication of
> > > > > > > > > whether the new mm APIs make sense.
> > > > > > > >
> > > > > > > > The problem is the infrastructure as implemented isn't designed to do
> > > > > > > > that. I am pretty certain this interface will have issues with being
> > > > > > > > given small blocks to process at a time.
> > > > > > > >
> > > > > > > > Basically the design for the FREE_PAGE_HINT feature doesn't really
> > > > > > > > have the concept of doing things a bit at a time. It is either
> > > > > > > > filling, stopped, or done. From what I can tell it requires a
> > > > > > > > configuration change for the virtio balloon interface to toggle
> > > > > > > > between those states.
> > > > > > >
> > > > > > > Maybe I misunderstand what you are saying.
> > > > > > >
> > > > > > > Filling state can definitely report things
> > > > > > > a bit at a time. It does not assume that
> > > > > > > all of guest free memory can fit in a VQ.
> > > > > >
> > > > > > I think where you and I may differ is that you are okay with just
> > > > > > pulling pages until you hit OOM, or allocation failures. Do I have
> > > > > > that right?
> > > > >
> > > > > This is exactly what the current code does. But that's an implementation
> > > > > detail which came about because we failed to find any other way to
> > > > > iterate over free blocks.
> > > >
> > > > I get that. However my concern is that permeated other areas of the
> > > > implementation that make taking another approach much more difficult
> > > > than it needs to be.
> > >
> > > Implementation would have to change to use an iterator obviously. But I don't see
> > > that it leaked out to a hypervisor interface.
> > >
> > > In fact take a look at virtio_balloon_shrinker_scan
> > > and you will see that it calls shrink_free_pages
> > > without waiting for the device at all.
> >
> > Yes, and in case you missed it earlier I am pretty sure that leads to
> > possible memory corruption. I don't think it was tested enough to be
> > able to say that is safe.
>
> More testing would be good, for sure.
>
> > Specifically we cannot be clearing the dirty flag on pages that are in
> > use. We should only be clearing that flag for pages that are
> > guaranteed to not be in use.
>
> I think that clearing the dirty flag is safe if the flag was originally
> set and the page has been
> write-protected before reporting was requested.
> In that case we know that page has not been changed.
> Right?

I am just going to drop the rest of this thread as I agree we have
been running ourselves around in circles. The part I had missed was
the part where there are 2 bitmaps and that you are are using
migration_bitmap_sync_precopy() to align the two.

This is just running at the same time as the precopy code and is only
really meant to try and clear the bit before the precopy gets to it
from what I can tell.

So one thing that is still an issue then is that my approach would
only work on the first migration. The problem is the logic I have
implemented assumes that once we have hinted on a page we don't need
to do it again. However in order to support migration you would need
to reset the hinting entirely and start over again after doing a
migration.

