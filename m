Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 154ABC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 12:18:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1540206A2
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 12:18:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ls2sEpPF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1540206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D2C96B0003; Tue,  2 Jul 2019 08:18:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 460468E0003; Tue,  2 Jul 2019 08:18:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FD618E0001; Tue,  2 Jul 2019 08:18:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 032C86B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 08:18:16 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id a21so8892749otk.17
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 05:18:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=EQFPfKnigVqvBSqD9eQKtRGLDR0XGFyOvketyNfarh4=;
        b=MN0jPIIBCjc4AH4xnLtJKasm1PgqYX3w+pNjdL3iB10msaCdXEUKM2sSsCJm6ArAye
         t98lgc4J7iDOk8CLvljqh+IaeRtDhu+HqkMP8eBm2yDKAivJk8B6n6UaslNUt5dnP2Ny
         4YWcQoeBbYVk33LmrcKStK6jEMroYaZ7fyJDiUx5OjaJU/L1sCQtzZR76GanMUefoqTQ
         nihPN5032MUb6t/LgKZuaLgfabUy+70XXTlNa3xEsUJ0RJo/sho/o9GFB66QRSmQUCKH
         ShWWCQh/w6+2QNk4H5yOpoPJh6KjRA3HN2pyRV/Ho1L9Suw8ibss/y9ASrOle6tmlEw2
         ZI9Q==
X-Gm-Message-State: APjAAAVIqDTHKOTkuoMSp1t2pH8WGCF+c7/LN/txb291sii/EzXuj94G
	PSn0Vrwg5RYk0n9CVztz9kFeRXezrBpi37Og9Gwx+d3J3i1iOMmtn3Iqln/kE1G71yfVYj+zXo9
	EK78xfPBIOhY6dBNeaP33SusG6LfHzk8hon18LA/AH9xDefnRqJ/mO6r8wtpGP64+hw==
X-Received: by 2002:a9d:12a9:: with SMTP id g38mr23979002otg.125.1562069895663;
        Tue, 02 Jul 2019 05:18:15 -0700 (PDT)
X-Received: by 2002:a9d:12a9:: with SMTP id g38mr23978963otg.125.1562069894911;
        Tue, 02 Jul 2019 05:18:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562069894; cv=none;
        d=google.com; s=arc-20160816;
        b=XSnUylwDtrp1Rd1HvQlvE4Zg4KJPyzxMDGRZztgiAf78XtNdt9QdZsHX9CQTKAcDAI
         yr87Ys5S47QZJiaDha1jf1vpIYcmCQcd1hXyJUVmFe2cPXQsszQkVWevyY1K8UK+sD6S
         1BhaRNlFfmMf+0Ts1Arsl1UZs31L5XVTAW8sC9drPkQQ105KPcYxIKZhjOm80+kcyM/h
         yc4F0bOR0ZLkGiARJB05UCFonL3zy5U7PQpli8Yu6g2DutBkiyIVPmywuEzXi6D+rcqk
         tdvtb46gU/MmtDyJ6XpAiAWJXqHc53tyQa59c/BS9znJw4v4P+ujS/npnweKOQrUC9lA
         vicA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=EQFPfKnigVqvBSqD9eQKtRGLDR0XGFyOvketyNfarh4=;
        b=VbU+dc+3wg7CEEjIHTjI/ihwbB39IEFarAh3Y8hYBlCXsKzDc6WGSr31FtTNhiRm0N
         K2MTsTzSA7KKQyLkBiKfbSUDj7RZMW4d1/JeegOidY2AS6+JOnbpCSDnygYpVQE1q6yg
         j1bd07zf5yt5sj8YxhI7vwduLiucns68nu6n+n46+HZsIhy2NccFZukUAntZfD2u19kM
         ipE2OqDy67n6hxEfrGbJ8WUsl/UHPQmhC1kCaLCG9ctndRs8G5PrQV+nS3dhoDl9Rmwb
         +qiI7TYSefO66xDWKOmWuRwlbWkSw1WR2rXyBVviwUCN1fWmPj6pVy1ddT3LWtqXM/76
         XCrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ls2sEpPF;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n129sor6199187oif.116.2019.07.02.05.18.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 05:18:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ls2sEpPF;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=EQFPfKnigVqvBSqD9eQKtRGLDR0XGFyOvketyNfarh4=;
        b=ls2sEpPFocepLR1LGzbnqUzUwF+ciDgl01tJ7V/hLHyZtwBlogxVkrUQFcWfjlxIvu
         q+nn6CIlHJBl7dcMXZJ90rSMk+VevPYy6tQjj/sW0ugvjNiEBpZuTQCGH2zF8lU52T26
         iVKmoD3dbzIMHqCHvQ5odNKYUmzon2UFN0V5pr108k4+aDXs+lmAcaP9f1IvRZC0A+UY
         NE3kzN9l1fPaqSTDpH1wrPsOTRuPHgIoILtDfPn/yh2jkBIw1hiyPTg3F0LMRHf3miCh
         FELJ2Y/H8vxeYrHTPwMhYh+shlDV/cQna94UoGmpMUChneBkvz2R8ZIXP4k/4ndhUxQK
         l3NA==
X-Google-Smtp-Source: APXvYqyt7Ig9UUzbNaFPCtBVZS+wdjqfYzgY/wZ2HVVvdVJosrc4gzvrc4xAGX15Elp6hune+llTQZ21TxydrUFTt6U=
X-Received: by 2002:a05:6808:1d9:: with SMTP id x25mr2660841oic.21.1562069894627;
 Tue, 02 Jul 2019 05:18:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190630075650.8516-1-lpf.vector@gmail.com> <20190701092037.GL6376@dhcp22.suse.cz>
 <20190701101121.kyg65fbcd7reszk7@pc636>
In-Reply-To: <20190701101121.kyg65fbcd7reszk7@pc636>
From: oddtux <lpf.vector@gmail.com>
Date: Tue, 2 Jul 2019 20:18:03 +0800
Message-ID: <CAD7_sbEwxk-avBMONmihHOeKAnWoeANLQ7cR6LBO2YfzJ5Q8kw@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm/vmalloc.c: improve readability and rewrite vmap_area
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, peterz@infradead.org, 
	rpenyaev@suse.de, guro@fb.com, aryabinin@virtuozzo.com, rppt@linux.ibm.com, 
	mingo@kernel.org, rick.p.edgecombe@intel.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Uladzislau Rezki <urezki@gmail.com> =E4=BA=8E2019=E5=B9=B47=E6=9C=881=E6=97=
=A5=E5=91=A8=E4=B8=80 =E4=B8=8B=E5=8D=886:11=E5=86=99=E9=81=93=EF=BC=9A
>
> On Mon, Jul 01, 2019 at 11:20:37AM +0200, Michal Hocko wrote:
> > On Sun 30-06-19 15:56:45, Pengfei Li wrote:
> > > Hi,
> > >
> > > This series of patches is to reduce the size of struct vmap_area.
> > >
> > > Since the members of struct vmap_area are not being used at the same =
time,
> > > it is possible to reduce its size by placing several members that are=
 not
> > > used at the same time in a union.
> > >
> > > The first 4 patches did some preparatory work for this and improved
> > > readability.
> > >
> > > The fifth patch is the main patch, it did the work of rewriting vmap_=
area.
> > >
> > > More details can be obtained from the commit message.
> >
> > None of the commit messages talk about the motivation. Why do we want t=
o
> > add quite some code to achieve this? How much do we save? This all
> > should be a part of the cover letter.
> >
> > > Thanks,
> > >
> > > Pengfei
> > >
> > > Pengfei Li (5):
> > >   mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
> > >   mm/vmalloc.c: Introduce a wrapper function of
> > >     insert_vmap_area_augment()
> > >   mm/vmalloc.c: Rename function __find_vmap_area() for readability
> > >   mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readabil=
ity
> > >   mm/vmalloc.c: Rewrite struct vmap_area to reduce its size
> > >
> > >  include/linux/vmalloc.h |  28 +++++---
> > >  mm/vmalloc.c            | 144 +++++++++++++++++++++++++++-----------=
--
> > >  2 files changed, 117 insertions(+), 55 deletions(-)
> > >
> > > --
> > > 2.21.0
>
> > > Pengfei Li (5):
> > >   mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
> > >   mm/vmalloc.c: Introduce a wrapper function of
> > >     insert_vmap_area_augment()
> > >   mm/vmalloc.c: Rename function __find_vmap_area() for readability
> > >   mm/vmalloc.c: Modify function merge_or_add_vmap_area() for readabil=
ity
> > >   mm/vmalloc.c: Rewrite struct vmap_area to reduce its size
> Fitting vmap_area to 1 cacheline boundary makes sense to me. I was thinki=
ng about
> that and i have patches in my pipeline to send out but implementation is =
different.
>
> I had a look at all 5 patches. What you are doing is reasonable to me, i =
mean when
> it comes to the idea of reducing the size to L1 cache line.
>

Thank you for your review.

> I have a concern about implementation and all logic around when we can us=
e va_start
> and when it is something else. It is not optimal at least to me, from per=
formance point
> of view and complexity. All hot paths and tree traversal are affected by =
that.
>
> For example running the vmalloc test driver against this series shows the=
 following
> delta:
>
> <5.2.0-rc6+>
> Summary: fix_size_alloc_test passed: loops: 1000000 avg: 969370 usec
> Summary: full_fit_alloc_test passed: loops: 1000000 avg: 989619 usec
> Summary: long_busy_list_alloc_test loops: 1000000 avg: 12895813 usec
> <5.2.0-rc6+>
>
> <this series>
> Summary: fix_size_alloc_test passed: loops: 1000000 avg: 1098372 usec
> Summary: full_fit_alloc_test passed: loops: 1000000 avg: 1167260 usec
> Summary: long_busy_list_alloc_test passed: loops: 1000000 avg: 12934286 u=
sec
> <this series>
>
> For example, the degrade in second test is ~15%.
>
> --
> Vlad Rezki

Hi, Vlad

I think the reason for the performance degradation is that the value
of va_start is obtained by va->vm->addr.

And since the vmap area in the BUSY tree is always page-aligned,
there is no reason for _va_vmlid to override va_start, just let
the va->flags use the bits that lower than PAGE_OFFSET.

I will use this implementation in the next version and show almost
no performance penalty in my local tests.

I will send the next version soon.

Thank you for taking your time for the review.

Best regards,

Pengfei

