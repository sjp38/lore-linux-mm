Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECF6BC48BE0
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 21:54:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8637321721
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 21:54:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="WBbtV67P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8637321721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAA136B0003; Wed, 19 Jun 2019 17:54:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C59C48E0002; Wed, 19 Jun 2019 17:54:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B21468E0001; Wed, 19 Jun 2019 17:54:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA546B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 17:54:07 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id t198so238666oih.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 14:54:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=JrmPkmGlWIDmfFJHcUBHoDgjBA4Uq/PsSzropCIymmw=;
        b=VY9xMYqpzrFNJkeffdwNMMS5HC8nDshym3THaoHNdE52Ia3hJsFwgKykNRqafpC0+v
         imZYVCf+eaLYX7pNJuJbEBKBQnxiF5hzqEZLqC2X1qoQZc5YtSod8qzMnBZHscNxNBGL
         alTudD/JkBk8RMn6c5atSnVLJ0fHnEOiGkUDMvyYoTKMUDzsZWZuOdDY0HcLB0W4zN7Q
         E4f0p+VYB3g5hyW+znqGO7KhnkuIwyG64BOFoedXXr/w6BvBBBYhz4I1fv9PKmlkkj/F
         JFF0H1f2QU6k175PKXLzmWJtIq3wWgsjI8+ZQsXdsIljPW2SYfDk1dv5DPBePzd1PybW
         jAuw==
X-Gm-Message-State: APjAAAWdVwqg9IxWSCEUoQ6ttNjVhZie6u5RDNiptEnIQWIEr/kDx3Tj
	TIZVg6ojrVGxYjbqKvOED2uhKWDWTQsMgdeCdSwOkyGjzeYe8xf6supyyeHstXmeEMwdcfeqwgL
	7d3nK0v0aBCC5kCdJr8LEePcOT8+UIYmEJCh5wkiT5knX6Kyq3wF87HHZSh96yVV17A==
X-Received: by 2002:aca:5346:: with SMTP id h67mr4012805oib.55.1560981247152;
        Wed, 19 Jun 2019 14:54:07 -0700 (PDT)
X-Received: by 2002:aca:5346:: with SMTP id h67mr4012782oib.55.1560981246253;
        Wed, 19 Jun 2019 14:54:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560981246; cv=none;
        d=google.com; s=arc-20160816;
        b=dMfgpm6VGREOyUOqM2/NHysjLStjp2qFQkmbpPmRQFXOZ8QzgnzGGMKIGXfQxoWp2E
         wTGHFeGZgZBOoX+cs3hzn+dmu2tuqhLZDZ1ov6umyPDQBFJph9cBjJNbi0nEalNaM2bO
         ALGbVQ7/LNEMQNUQsjbJuKVaAyqnyigYxm0ZVyKCi/VWXGfOiitP5SbWWK1ZixOF4xhZ
         grGJ2iuPMd4Yu2vNfM5dmkTIxpSaeVy4FNZ3fEXPBgNKYYzpTCYXetcQJr5xTDcS465e
         +yNvdFHGAZyC1wuCFNNENgip7pdW17E3jxR7mFSCm8/3mlRlZwxPu3Jk5LfleNWtaUa+
         BKMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=JrmPkmGlWIDmfFJHcUBHoDgjBA4Uq/PsSzropCIymmw=;
        b=X7JHyvewkoxeI6qLSQcQmLD64WCYznjUCmdM3crwQmXvKw/mjuqhZgD2de8oWPx7oC
         VRX6x4Zv99w/5BJ6mDho0CioyaWVBJBO0XEy/YLWEogrv7i0cU5R2bshPlgAdzIm53iJ
         EdHYmWXBjdriVvyQUwpTB2HdtFBYxPqmhDvrV5S2qRBJ8uEcaPqb6tWTK6ehav7PdnWl
         +BVhXfgPbXi28Fcns1jCSxQhHQV5RGloTtPJariP/32a72ddl+24UDNN4GpjaSUGMngE
         y1mWHMh+S2jEIhLjfhyizARMexKo9JmHJVfsohGlePHiWITiJzYzzKPHrwjf7lEK+nkD
         W0sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=WBbtV67P;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5sor4561214oig.153.2019.06.19.14.54.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 14:54:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=WBbtV67P;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=JrmPkmGlWIDmfFJHcUBHoDgjBA4Uq/PsSzropCIymmw=;
        b=WBbtV67PxlzWF1EF3D6ymPFrOUmHY0N0WW50GNMKS5/RKjY/r32FX/pN++Js56UrJW
         f/s7KDuhhbquot8VyWdYdbu1K4N6mZUSD30XrAOyqxYOcnWlBG3Rj2ZKM+tPxujVXYB1
         lWBLXB0NfhGXLAp7U1ISHE/MOSc+mHZlYUWYqZ3OMl+Ypm4Rxl/7aE4WuAkQ8OqkUUrb
         PgyCZA2GRtAs+sU1e0zD09j1iJl5H+Ff+Y5OV59gAlbHUKH00ZFnw4huGYE6vsTIzxrS
         Xhg+kRwWUcOvamuVw/0FKyGf4fVEibUff2E2RH/Q1BcNXHe6UPy+167cFU99QhZNgxI7
         RK0w==
X-Google-Smtp-Source: APXvYqxcjUnD4FIHV2bGaEcKpzuyLnsiNdvlDaM+9QH4AEKqN4Y/h5h0tSXn91LvSGHhJ7SPRgQdZkHoTuGUd9kflFo=
X-Received: by 2002:aca:1304:: with SMTP id e4mr4306999oii.149.1560981245880;
 Wed, 19 Jun 2019 14:54:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190613045903.4922-1-namit@vmware.com> <20190613045903.4922-4-namit@vmware.com>
 <20190617215750.8e46ae846c09cd5c1f22fdf9@linux-foundation.org>
 <98464609-8F5A-47B9-A64E-2F67809737AD@vmware.com> <8072D878-BBF2-47E4-B4C9-190F379F6221@vmware.com>
 <CAErSpo5eiweMk2rfT81Kwnpd=MZsOa01prPo_rAFp-MZ9F2xdQ@mail.gmail.com>
In-Reply-To: <CAErSpo5eiweMk2rfT81Kwnpd=MZsOa01prPo_rAFp-MZ9F2xdQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 19 Jun 2019 14:53:54 -0700
Message-ID: <CAPcyv4iAbWnWUT2d2VhnvuHvJE0-Vxgbf1TYtOPjkR6j3qROtw@mail.gmail.com>
Subject: Re: [PATCH 3/3] resource: Introduce resource cache
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Nadav Amit <namit@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra <peterz@infradead.org>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, 
	"Kleen, Andi" <andi.kleen@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ add Andi ]

On Wed, Jun 19, 2019 at 6:00 AM Bjorn Helgaas <bhelgaas@google.com> wrote:
>
> On Tue, Jun 18, 2019 at 12:40 AM Nadav Amit <namit@vmware.com> wrote:
> >
> > > On Jun 17, 2019, at 10:33 PM, Nadav Amit <namit@vmware.com> wrote:
> > >
> > >> On Jun 17, 2019, at 9:57 PM, Andrew Morton <akpm@linux-foundation.or=
g> wrote:
> > >>
> > >> On Wed, 12 Jun 2019 21:59:03 -0700 Nadav Amit <namit@vmware.com> wro=
te:
> > >>
> > >>> For efficient search of resources, as needed to determine the memor=
y
> > >>> type for dax page-faults, introduce a cache of the most recently us=
ed
> > >>> top-level resource. Caching the top-level should be safe as ranges =
in
> > >>> that level do not overlap (unlike those of lower levels).
> > >>>
> > >>> Keep the cache per-cpu to avoid possible contention. Whenever a res=
ource
> > >>> is added, removed or changed, invalidate all the resources. The
> > >>> invalidation takes place when the resource_lock is taken for write,
> > >>> preventing possible races.
> > >>>
> > >>> This patch provides relatively small performance improvements over =
the
> > >>> previous patch (~0.5% on sysbench), but can benefit systems with ma=
ny
> > >>> resources.
> > >>
> > >>> --- a/kernel/resource.c
> > >>> +++ b/kernel/resource.c
> > >>> @@ -53,6 +53,12 @@ struct resource_constraint {
> > >>>
> > >>> static DEFINE_RWLOCK(resource_lock);
> > >>>
> > >>> +/*
> > >>> + * Cache of the top-level resource that was most recently use by
> > >>> + * find_next_iomem_res().
> > >>> + */
> > >>> +static DEFINE_PER_CPU(struct resource *, resource_cache);
> > >>
> > >> A per-cpu cache which is accessed under a kernel-wide read_lock look=
s a
> > >> bit odd - the latency getting at that rwlock will swamp the benefit =
of
> > >> isolating the CPUs from each other when accessing resource_cache.
> > >>
> > >> On the other hand, if we have multiple CPUs running
> > >> find_next_iomem_res() concurrently then yes, I see the benefit.  Has
> > >> the benefit of using a per-cpu cache (rather than a kernel-wide one)
> > >> been quantified?
> > >
> > > No. I am not sure how easy it would be to measure it. On the other ha=
nder
> > > the lock is not supposed to be contended (at most cases). At the time=
 I saw
> > > numbers that showed that stores to =E2=80=9Cexclusive" cache lines ca=
n be as
> > > expensive as atomic operations [1]. I am not sure how up to date thes=
e
> > > numbers are though. In the benchmark I ran, multiple CPUs ran
> > > find_next_iomem_res() concurrently.
> > >
> > > [1] http://sigops.org/s/conferences/sosp/2013/papers/p33-david.pdf
> >
> > Just to clarify - the main motivation behind the per-cpu variable is no=
t
> > about contention, but about the fact the different processes/threads th=
at
> > run concurrently might use different resources.
>
> IIUC, the underlying problem is that dax relies heavily on ioremap(),
> and ioremap() on x86 takes too long because it relies on
> find_next_iomem_res() via the __ioremap_caller() ->
> __ioremap_check_mem() -> walk_mem_res() path.
>
> The fact that x86 is the only arch that does this much work in
> ioremap() makes me wonder.  Is there something unique about x86
> mapping attributes that requires this extra work, or is there some way
> this could be reworked to avoid searching the resource map in the
> first place?

The underlying issue is that the x86-PAT implementation wants to
ensure that conflicting mappings are not set up for the same physical
address. This is mentioned in the developer manuals as problematic on
some cpus. Andi, is lookup_memtype() and track_pfn_insert() still
relevant?

