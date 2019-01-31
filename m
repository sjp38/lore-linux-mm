Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A7A7C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:13:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE316207E0
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:13:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WsGlgijO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE316207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 326B58E0002; Thu, 31 Jan 2019 05:13:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ADD48E0001; Thu, 31 Jan 2019 05:13:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19DEA8E0002; Thu, 31 Jan 2019 05:13:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A071B8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:13:54 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id z5-v6so491939ljb.13
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:13:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=i7aqIU67iTXfnMOyJql1uNrnoPFgHw1gIYpbByUl8SQ=;
        b=REnHh4uifDPt/lK8IOmXqTjx0uYG5mNkSXzHlsnd96O2C86+pX7LtSqZAzHpBfVEGe
         +oZtjjqynAeDHDVCOeTRzJIrq4syXiqOO4118NajmHsHhhdThKtOMK/f2NpCbjJodRKK
         k9W8NsmjEdGWmiuQ3x71JfILC3bByw0d7uOKH2gOhqtf4gH1MbO7ndedtB4tPfUCs6a7
         Uw8IsGQ3lXSBCxReiLpMPOHG8nEuEtGeWOVk/HNFEq4w9u565JU3/vzLEvfelu3cNDLo
         zkQ+nMwSbAw7y2H0CFIlEgqXd4sbt4FLkQg3S4T5LU4UoVCkC9kv9opZIsKWpytGlVHv
         WbwA==
X-Gm-Message-State: AJcUukdv5g3gi9MsciYqKRj8DNgvpF+Va8Yyfwwd0LW9L7rpp9XAjJEp
	c9KeurSHZXh0FbnZ1za8tfxUv1DxjNizN2JBMeVa/bgn3l07U/zRra17vxsZ9wKONV3ySBP5nCE
	YIGhLX9KZcos5/iPS7UiBRQ7gWNfr1LBEeA4eLKd1qDdmYAWknLCicsi+dZRMvIcFEqWv+44pf1
	w5RPyQhXh7F0R5G4E9QGhLpVrTNpC93VozMp2HE/AVVwcUWQ7z5pqtMYML4sFJuGPwKKf8sFY7I
	UgSssAVhRUkiPzcVV+o7LFfypGqzCRCVw1EKWrIgRfP+QlEQE97affmA/nRxx5PVM8SYmlWISEF
	XefErZiESPFhm0GHtQaw9WvWMwJXSggvU2++Hq5yiLiuVJP1XGrBtul2sJ2nn/izozxmcdTSk7q
	p
X-Received: by 2002:a19:d242:: with SMTP id j63mr28113365lfg.26.1548929633790;
        Thu, 31 Jan 2019 02:13:53 -0800 (PST)
X-Received: by 2002:a19:d242:: with SMTP id j63mr28113305lfg.26.1548929632577;
        Thu, 31 Jan 2019 02:13:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548929632; cv=none;
        d=google.com; s=arc-20160816;
        b=Ek2G/uU01Ww0fy1QmvXhL0h7JJiKkk3w9KWvsK/PB/cLATTMm9dMVNO3FEm5HwQ/GM
         7VFkg4HXH3XcnZNet3NWNGoTmJI7YKf+0onkOLf8dBhy+9wZ8cxhv60ZJEQOIYQYl+qv
         uEoMGm/qYnpi9wCC3rUcn+LGNiyLl11l/NMyBI9WhYVcKRgM+i+rG8ClGWFc0IgJEJ87
         EOPkM7VMtrYsRXmAtUQbnMzAAq2bAIkl0t7yX0iR3dCnnAYs3emtGmUBYSKeOCah7OCV
         SPav3uKQIBKy2dHrvh+bk7suwIqUx0YrKj1LvxgGGoVtPDosz2AlpkdU5HuQohtrQ86Q
         ybqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=i7aqIU67iTXfnMOyJql1uNrnoPFgHw1gIYpbByUl8SQ=;
        b=nHzVegLNqiGyRkg4i2GKwWJO5Juc5He84kEYBCFWZbY5KoMYOXgeuhl3O8ZJsT/xvD
         pS3k6wEi4DcJy+P5gV6kKSUIhVb89tG0beliIDvGNZOlGwJakuVBDPm4v82Dv0H+y3sA
         vk/i2qG2BncHYwzsaBiF3r0x4B+us3cqjF53g3a+URJMFNbcVFi2IGFuo5y+7l5NAdZP
         xhL08No/LcYRPDpZQudZ76XzPbEzaK5GwCS1Fq+/XBzpzk7ZfzOVAn3FGSePM7mlb+9s
         uoTk0Z+IGVfhWdYBtIB9O6M650mM12StfInxGYRvSOgyCl7X7XG4b4hXEOtOLmnkVUR9
         G+jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WsGlgijO;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f8-v6sor2890192ljg.0.2019.01.31.02.13.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 02:13:52 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WsGlgijO;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=i7aqIU67iTXfnMOyJql1uNrnoPFgHw1gIYpbByUl8SQ=;
        b=WsGlgijO3cknHXg1mEI+dHF6KGXSU6wDgOORDOLKHOpHi0m1l1JKujU0tp7ZlYc9P/
         bRvhwLAUOzl9V9aJKStjWeHqNi4xsROdHbSBe53DVTdSScRktYADRRc0vzdv4cDiTm4F
         9T0KugzXwzP85vvF8hZbi+Se8r6pYBcDfIVI+SFvtze0wl2aemZC+nP2bxGrTNkR/7xE
         1Y+PLTRpZfThQ6XeAl/2KYZ5vQmW4Y2XZbdwT9uvbzK5lrEBldjdC5GRg3M2nLtBgyd3
         bhICRRdwsmbCEkyPJP7Tv3yA1gAf/1TfDAGqj8hQQhNaq8AJI6KmXOirb7XINlvrjq/3
         MF+g==
X-Google-Smtp-Source: ALg8bN5d9Tpv6yTO6iC1E2jXBwzQgeTYpfILSW2IqBb3XFVwUI9hGn0qP+a8Il7n8MA2pe75YkgVoxkOXZD+HBbfEaQ=
X-Received: by 2002:a2e:9849:: with SMTP id e9-v6mr27364491ljj.9.1548929631905;
 Thu, 31 Jan 2019 02:13:51 -0800 (PST)
MIME-Version: 1.0
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC> <20190131083842.GE28876@rapoport-lnx>
In-Reply-To: <20190131083842.GE28876@rapoport-lnx>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 31 Jan 2019 15:43:39 +0530
Message-ID: <CAFqt6zbG089qCYBoZ8HCHPaRm+Yi=gHNboxy9y_qw9eVpSFjag@mail.gmail.com>
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, 
	Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, 
	iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, 
	Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, 
	joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, 
	mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, 
	linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, 
	linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, 
	iommu@lists.linux-foundation.org, linux-media@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 2:09 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Thu, Jan 31, 2019 at 08:38:12AM +0530, Souptick Joarder wrote:
> > Previouly drivers have their own way of mapping range of
> > kernel pages/memory into user vma and this was done by
> > invoking vm_insert_page() within a loop.
> >
> > As this pattern is common across different drivers, it can
> > be generalized by creating new functions and use it across
> > the drivers.
> >
> > vm_insert_range() is the API which could be used to mapped
> > kernel memory/pages in drivers which has considered vm_pgoff
> >
> > vm_insert_range_buggy() is the API which could be used to map
> > range of kernel memory/pages in drivers which has not considered
> > vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
> >
> > We _could_ then at a later "fix" these drivers which are using
> > vm_insert_range_buggy() to behave according to the normal vm_pgoff
> > offsetting simply by removing the _buggy suffix on the function
> > name and if that causes regressions, it gives us an easy way to revert.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Suggested-by: Russell King <linux@armlinux.org.uk>
> > Suggested-by: Matthew Wilcox <willy@infradead.org>
> > ---
> >  include/linux/mm.h |  4 +++
> >  mm/memory.c        | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  mm/nommu.c         | 14 ++++++++++
> >  3 files changed, 99 insertions(+)
> >
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 80bb640..25752b0 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -2565,6 +2565,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
> >  int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
> >                       unsigned long pfn, unsigned long size, pgprot_t);
> >  int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
> > +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > +                             unsigned long num);
> > +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> > +                             unsigned long num);
> >  vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
> >                       unsigned long pfn);
> >  vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
> > diff --git a/mm/memory.c b/mm/memory.c
> > index e11ca9d..0a4bf57 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1520,6 +1520,87 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
> >  }
> >  EXPORT_SYMBOL(vm_insert_page);
> >
> > +/**
> > + * __vm_insert_range - insert range of kernel pages into user vma
> > + * @vma: user vma to map to
> > + * @pages: pointer to array of source kernel pages
> > + * @num: number of pages in page array
> > + * @offset: user's requested vm_pgoff
> > + *
> > + * This allows drivers to insert range of kernel pages they've allocated
> > + * into a user vma.
> > + *
> > + * If we fail to insert any page into the vma, the function will return
> > + * immediately leaving any previously inserted pages present.  Callers
> > + * from the mmap handler may immediately return the error as their caller
> > + * will destroy the vma, removing any successfully inserted pages. Other
> > + * callers should make their own arrangements for calling unmap_region().
> > + *
> > + * Context: Process context.
> > + * Return: 0 on success and error code otherwise.
> > + */
> > +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > +                             unsigned long num, unsigned long offset)
> > +{
> > +     unsigned long count = vma_pages(vma);
> > +     unsigned long uaddr = vma->vm_start;
> > +     int ret, i;
> > +
> > +     /* Fail if the user requested offset is beyond the end of the object */
> > +     if (offset > num)
> > +             return -ENXIO;
> > +
> > +     /* Fail if the user requested size exceeds available object size */
> > +     if (count > num - offset)
> > +             return -ENXIO;
> > +
> > +     for (i = 0; i < count; i++) {
> > +             ret = vm_insert_page(vma, uaddr, pages[offset + i]);
> > +             if (ret < 0)
> > +                     return ret;
> > +             uaddr += PAGE_SIZE;
> > +     }
> > +
> > +     return 0;
> > +}
> > +
> > +/**
> > + * vm_insert_range - insert range of kernel pages starts with non zero offset
> > + * @vma: user vma to map to
> > + * @pages: pointer to array of source kernel pages
> > + * @num: number of pages in page array
> > + *
> > + * Maps an object consisting of `num' `pages', catering for the user's
> > + * requested vm_pgoff
> > + *
>
> The elaborate description you've added to __vm_insert_range() is better put
> here, as this is the "public" function.

Ok, will add it in v3. Which means __vm_insert_range() still needs a short
description ?
>
> > + * Context: Process context. Called by mmap handlers.
> > + * Return: 0 on success and error code otherwise.
> > + */
> > +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > +                             unsigned long num)
> > +{
> > +     return __vm_insert_range(vma, pages, num, vma->vm_pgoff);
> > +}
> > +EXPORT_SYMBOL(vm_insert_range);
> > +
> > +/**
> > + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> > + * @vma: user vma to map to
> > + * @pages: pointer to array of source kernel pages
> > + * @num: number of pages in page array
> > + *
> > + * Maps a set of pages, always starting at page[0]
>
> Here I'd add something like:
>
> Similar to vm_insert_range(), except that it explicitly sets @vm_pgoff to
> 0. This function is intended for the drivers that did not consider
> @vm_pgoff.

Ok.

>
> > vm_insert_range_buggy() is the API which could be used to map
> > range of kernel memory/pages in drivers which has not considered
> > vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
>
> > + *
> > + * Context: Process context. Called by mmap handlers.
> > + * Return: 0 on success and error code otherwise.
> > + */
> > +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> > +                             unsigned long num)
> > +{
> > +     return __vm_insert_range(vma, pages, num, 0);
> > +}
> > +EXPORT_SYMBOL(vm_insert_range_buggy);
> > +
> >  static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
> >                       pfn_t pfn, pgprot_t prot, bool mkwrite)
> >  {
> > diff --git a/mm/nommu.c b/mm/nommu.c
> > index 749276b..21d101e 100644
> > --- a/mm/nommu.c
> > +++ b/mm/nommu.c
> > @@ -473,6 +473,20 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
> >  }
> >  EXPORT_SYMBOL(vm_insert_page);
> >
> > +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > +                     unsigned long num)
> > +{
> > +     return -EINVAL;
> > +}
> > +EXPORT_SYMBOL(vm_insert_range);
> > +
> > +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> > +                             unsigned long num)
> > +{
> > +     return -EINVAL;
> > +}
> > +EXPORT_SYMBOL(vm_insert_range_buggy);
> > +
> >  /*
> >   *  sys_brk() for the most part doesn't need the global kernel
> >   *  lock, except when an application is doing something nasty
> > --
> > 1.9.1
> >
>
> --
> Sincerely yours,
> Mike.
>

