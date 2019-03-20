Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF574C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:57:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A227E218B0
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:57:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="hQHtw54b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A227E218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C50D6B0006; Wed, 20 Mar 2019 16:57:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 473326B0007; Wed, 20 Mar 2019 16:57:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 362E86B0008; Wed, 20 Mar 2019 16:57:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 053186B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 16:57:38 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id q82so1767908oia.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 13:57:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ij6DJHAqfryzjiSG/jxMhd1XKTG9GJ9L0fy61wU1Z5Q=;
        b=WMKV+oT9PnKz7z7h9qD/YBMvrpvpSkU37f36klJYVtq6oCDa9rOft1wwlJMmlCWecl
         z0ZUHHOh8owZx6HdPy66OfmzqMSefSMIYD0FNfKgcFTmo8bRsRgX/l2UnIXcu4ihv2v+
         FPCjGDyBHC/QbXjpAh2zS4HAn/hua30d0Y+HGtUYS8gKCMdqkRGBXmyST5DeBFO48hYH
         s5C2bWT9xFlr0kT6s3Jy9MiHBMwAewjgjv69ja9dj7CKQ/wUD/W6T5VFsCeXR0UaGxZd
         IWIjS1fMta9uv4mGw3cSS0CHdTA/+FtbuCrYJJweuBFIbjzt2ebssGrwuXzoAlGep570
         HV2A==
X-Gm-Message-State: APjAAAUZoHxaUEQ08vSx4fieeYjSFuWgm7iZq41XFEjr68ZdeGKjx1A/
	GCIxx0Pj9zSdMG3dkadRvIJ/5jYG+cxQxVW4dc/IabM6Nz2Y5b0V/WiCqLLQ8/N4voqYx8of3ZQ
	qBicwtzyMH6TQip/lEZ7w9PAoNKrLPtr+d0vnyaQO1D4g1RH4dWEwjtz+CZcKNmlR4A==
X-Received: by 2002:aca:4c48:: with SMTP id z69mr6632799oia.147.1553115457690;
        Wed, 20 Mar 2019 13:57:37 -0700 (PDT)
X-Received: by 2002:aca:4c48:: with SMTP id z69mr6632727oia.147.1553115456089;
        Wed, 20 Mar 2019 13:57:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553115456; cv=none;
        d=google.com; s=arc-20160816;
        b=yJkVh6519MQKAzHIJdGkGxepHsgsyCcX1pKnnrSh3k6b4SiulqqNIn1WR1rNtoG4AQ
         FY5yBnky+6BuD0dBdMKpt8znxzrum1sd7zMeqh3h17VlZuyiJqlD1CPp1okOP0/QAQfM
         4ltEHhmMPuLRP9YRThQej5vmh70gHu++qmTHWXyICx5eOp5rz5TffsZtrrc60IrKnUd4
         zXXH4aDXiuUHHkwhYYjV5sfPwk/YA0dRUqyvQLYBcoDng27CG3Hb2HBajUlNjz6V0jLV
         ZZyvzWDp0pc+T5Mcl9ufFJSo8I85k4qX8HmfGfXSGPiccvYz/mtnv+8qaIcTK+TTaLO7
         AaFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ij6DJHAqfryzjiSG/jxMhd1XKTG9GJ9L0fy61wU1Z5Q=;
        b=KPWLKfneLVxXhuma47wnxPNqc+41sdu+kCv0m9vW5GmyN0gIj7F9COYh6E+ifINGaW
         1pR5bpkmPpL/AT1w+km6cRZXQPogeDEcFxAvqLu0sGml7SuXMqnsVbBK10equh9rIndG
         EUfvrDCjc/Tc05Usdho+rZPR+qv73Zq4l/XoMmwWCadVPV57aPWR5bolnQhMW2rgMcrZ
         r9zDo4diWJms8JrC7EWRx58zmr+ULYbnQLeoFtpGzaR8Sj7IwimJ3bFpBm5AydOMmPEK
         hwxkYWedHozIW8Vi7YhifplWg86x5tlReUBUJbA66cqOjyK6FlZ99ZMuifv+SSZGjIqH
         6J4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=hQHtw54b;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor2278186otj.16.2019.03.20.13.57.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 13:57:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=hQHtw54b;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ij6DJHAqfryzjiSG/jxMhd1XKTG9GJ9L0fy61wU1Z5Q=;
        b=hQHtw54bMsNq0UWUzqZi4Xepmmij8Jy+KDZGJeywwLNrPiqUxNyKDH9xKURLPj0fcE
         kgWIoCRrhrHXSjdOwmwJflndw0Hkzfn+dxWAhGaTjcdCUmKbGDvtLdps5Q5aNmZbyXWA
         3qpCDijWEutH+VhB1H3M03XG0EqvBDiHqQf8KpW7PktJ/3m/DRFeEcos1F+gSTr3sIrB
         Ad673In69dbKt/dX6+IzUFlmsJQdelglLg+znKplUjCEwy5y+QlPtMSJmrjZ01yzykjv
         KzrcWmFeOoSmQMh+oZa/9G1ooH7YeUyBLCBcskKekprWtQU1d7nwTXUeH25dBf7R+wDa
         oxlQ==
X-Google-Smtp-Source: APXvYqxcZXKMA+p2n96n1FFTaOSelIGH59iBkrJ6znV79aqILXhBWYIui9s4FGcIsTHT0hrIr2022s1bnFyAt264+ko=
X-Received: by 2002:a9d:4d0b:: with SMTP id n11mr63266otf.98.1553115455713;
 Wed, 20 Mar 2019 13:57:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
 <87k1hc8iqa.fsf@linux.ibm.com> <CAPcyv4ir4irASBQrZD_a6kMkEUt=XPUCuKajF75O7wDCgeG=7Q@mail.gmail.com>
 <871s3aqfup.fsf@linux.ibm.com> <CAPcyv4i0SahDP=_ZQV3RG_b5pMkjn-9Cjy7OpY2sm1PxLdO8jA@mail.gmail.com>
 <87bm267ywc.fsf@linux.ibm.com> <878sxa7ys5.fsf@linux.ibm.com> <CAPcyv4iuAPg3HWh5e8-Ud3oCrvp5AoFmjOzf4bbA+VLgR7NLFg@mail.gmail.com>
In-Reply-To: <CAPcyv4iuAPg3HWh5e8-Ud3oCrvp5AoFmjOzf4bbA+VLgR7NLFg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 20 Mar 2019 13:57:25 -0700
Message-ID: <CAPcyv4hMzVuOYzy2tTq-my8Z1y+X6Ug-fyObpKTxVU44p5rBZw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Ross Zwisler <zwisler@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 8:34 AM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Wed, Mar 20, 2019 at 1:09 AM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
> >
> > Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com> writes:
> >
> > > Dan Williams <dan.j.williams@intel.com> writes:
> > >
> > >>
> > >>> Now what will be page size used for mapping vmemmap?
> > >>
> > >> That's up to the architecture's vmemmap_populate() implementation.
> > >>
> > >>> Architectures
> > >>> possibly will use PMD_SIZE mapping if supported for vmemmap. Now a
> > >>> device-dax with struct page in the device will have pfn reserve area aligned
> > >>> to PAGE_SIZE with the above example? We can't map that using
> > >>> PMD_SIZE page size?
> > >>
> > >> IIUC, that's a different alignment. Currently that's handled by
> > >> padding the reservation area up to a section (128MB on x86) boundary,
> > >> but I'm working on patches to allow sub-section sized ranges to be
> > >> mapped.
> > >
> > > I am missing something w.r.t code. The below code align that using nd_pfn->align
> > >
> > >       if (nd_pfn->mode == PFN_MODE_PMEM) {
> > >               unsigned long memmap_size;
> > >
> > >               /*
> > >                * vmemmap_populate_hugepages() allocates the memmap array in
> > >                * HPAGE_SIZE chunks.
> > >                */
> > >               memmap_size = ALIGN(64 * npfns, HPAGE_SIZE);
> > >               offset = ALIGN(start + SZ_8K + memmap_size + dax_label_reserve,
> > >                               nd_pfn->align) - start;
> > >       }
> > >
> > > IIUC that is finding the offset where to put vmemmap start. And that has
> > > to be aligned to the page size with which we may end up mapping vmemmap
> > > area right?
>
> Right, that's the physical offset of where the vmemmap ends, and the
> memory to be mapped begins.
>
> > > Yes we find the npfns by aligning up using PAGES_PER_SECTION. But that
> > > is to compute howmany pfns we should map for this pfn dev right?
> > >
> >
> > Also i guess those 4K assumptions there is wrong?
>
> Yes, I think to support non-4K-PAGE_SIZE systems the 'pfn' metadata
> needs to be revved and the PAGE_SIZE needs to be recorded in the
> info-block.

How often does a system change page-size. Is it fixed or do
environment change it from one boot to the next? I'm thinking through
the behavior of what do when the recorded PAGE_SIZE in the info-block
does not match the current system page size. The simplest option is to
just fail the device and require it to be reconfigured. Is that
acceptable?

