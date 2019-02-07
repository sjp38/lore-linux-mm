Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54104C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:45:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 028B621872
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 15:45:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qG761ZJ4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 028B621872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85B028E0041; Thu,  7 Feb 2019 10:45:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82FC68E0002; Thu,  7 Feb 2019 10:45:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 746A88E0041; Thu,  7 Feb 2019 10:45:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0510F8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 10:45:42 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id v24-v6so74266ljj.10
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 07:45:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=O/NDPUvmhc7liFnvbt6y13+UwzEpiHVHRuajdML0aZE=;
        b=ncyfHIYvGnLyeANRb7BUy3CuUo5qq99Zy+6W7OcRmkkfC4KwGBeuBBvzGo0I24eihY
         SUB8jR8wW2KRDH28eHN45IGM0qp/XmEzRei1L2bUqQW/AC7omDGQRfpGJMiwJY4nOUaS
         E9ni/wYYwNkk7FRtMeIkZgbYYTm98VWwKbekaE8zpTbZ///PAonkLaiUrrciBLlfezuB
         NYFqomYDtRGAIQOfygEoHHGIXKmqcoxwgnRZAusExT20mAdmEr9LnaifVxyFnHEH1wBH
         woY+3YLtIjFavuDeXiMxeCPQmI9lybGYbeuJZHn2AO5ojeUSpq6a3zF8V1IIiHMjCgQc
         fW2A==
X-Gm-Message-State: AHQUAuaJyn8MyPPtFbofeF67Qk1UuRx/Waf/E8sV8OZAVMwR61RBlM4X
	zO6Gx89peP0VfQ17gyvAIKqboUzy9MlIEQ8U4h++hwSI4z16wlZHH5S+WF8YaGMMr4AnumTIVVv
	jA77buptdaN9fMhrezZm3jz4N53zIKiIH1jyy0wfkbqJFqhQGxoswAmlEQ/UXufUdpxcY7VWTcR
	YkYKxmHHXbLsQwZPtU+HEbcesilb8GL8R3c9THVTJlDv+QNgji2sj3ClW2S5QYhiBvRTXLuSrNk
	Wh/UzIKn9InvhYtlbHhc1/dDqhu8y7S55MxByeLslNgL75yse1HOVTGam1E+hly1EpO83WG9qyq
	+3dZb3B5+mYZ9uEbnKdJRTxGuO2L/q3V2iuF+hPHCXdIIIGSof4e5botthJDxoaveq3dh5GYUG2
	w
X-Received: by 2002:a19:aace:: with SMTP id t197mr10333421lfe.7.1549554341134;
        Thu, 07 Feb 2019 07:45:41 -0800 (PST)
X-Received: by 2002:a19:aace:: with SMTP id t197mr10333373lfe.7.1549554339889;
        Thu, 07 Feb 2019 07:45:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549554339; cv=none;
        d=google.com; s=arc-20160816;
        b=hQ34W+a0M5ns26P6Xy4VpK5J2mUWLVFx03f2lVD6Os6onEOVwVgsPMlfRpdOokK1gt
         oHLwuI1+yqecJdvXEpxOKiVzgcN7ne7qvYScEU5yRJCtREoQIRuEfoaDqZrFXpYe8IMs
         /mnAFx1lDj4cP3chqvZjoXol+BSSW9HD+IpANET41NNEAofRDFBPgRLinDziaxoka+45
         EYErt1iIjiPmYnx+nhe7qrI5J/9giBdGNxNHlyLDlcTqVg0EDGdf4DUr9RRA5nc4AFyE
         tRc0e602tBrRyaQfe8DebRlLAEOJvVizAxBH1WPO+2NjZkFiLNeBOfKfBoG1wOIh66ID
         Tkhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=O/NDPUvmhc7liFnvbt6y13+UwzEpiHVHRuajdML0aZE=;
        b=Q9ARcVldJ53j9bsO72DxJNYY5c16tSYOXtcqHq4urPgrkgcuViXkcBoPk9W6kOdtU0
         1hnRxcsBl+Np04jk8ozR86hVXlau4/HUnLDr+bhROdABDPySo4DIX/F5LnPot9GG9TEz
         hwXBQ2iSECRPKfcp+YZu2VwiRCxz0ltDvAkLJ5JDlE2W8brA3tWoLhuPHIZc6uSHgClR
         I9+yAuGtT1fWujFM0cZfKqIY0G1xOVok9n0dAG69c2MSIhinxZZpbILXWfwh5LWteBqF
         orMidv/j+Y2gbC8dIS82UUtYz0T+v6ZcVyb+dzQpLhpauxApnOL8h9QRFf5hISdn2tMU
         ItQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qG761ZJ4;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q23-v6sor15444854lji.14.2019.02.07.07.45.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 07:45:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qG761ZJ4;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=O/NDPUvmhc7liFnvbt6y13+UwzEpiHVHRuajdML0aZE=;
        b=qG761ZJ4JAzXfWf4k44vzqwTzwJdjw7HrMLbfG1ZctjDfX4AmZwvEAEci1Mvk5c/tO
         dx/AsCRD999RsyRjScsXZk1cF4SvMrbo0EHBqG7M6gagDU7RrepOTMBVJ0QvngXVdC4C
         asPeFulrVbB8TB5K9XbHruy7p7DuLl3xyaXwCBIkFFIM2WU2xP4PAwKMeW2CXk5RxCri
         9Q9SywOgwTjHgmlgb2mxpeDd/JAHJUPSg6p33yqmJ3WJLcrV8ldWK3NpbE644OabC0iA
         ySWILr/9OUhjnh56kYlr/R8o0akqI1Znp4lFuZzvqDKPr6QJDmScR9H7v4viyNnc/uUb
         jyhQ==
X-Google-Smtp-Source: AHgI3IbzB32ZxLY4eEONdPREgOSNHlby90vBWlr2L1uBsnqPtn/YWeju73oKE8ZL1X/0hLqt52nRIBXKfBEWtUoKRwY=
X-Received: by 2002:a2e:884b:: with SMTP id z11-v6mr3704699ljj.68.1549554339336;
 Thu, 07 Feb 2019 07:45:39 -0800 (PST)
MIME-Version: 1.0
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC> <20190131083842.GE28876@rapoport-lnx>
In-Reply-To: <20190131083842.GE28876@rapoport-lnx>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 7 Feb 2019 21:19:47 +0530
Message-ID: <CAFqt6za9xA_8OKiaaHXcO9go+RtPdjLY5Bz_fgQL+DZbermNhA@mail.gmail.com>
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

Hi Mike,

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

Just thought to take opinion for documentation before placing it in v3.
Does it looks fine ?

+/**
+ * __vm_insert_range - insert range of kernel pages into user vma
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ * @offset: user's requested vm_pgoff
+ *
+ * This allow drivers to insert range of kernel pages into a user vma.
+ *
+ * Return: 0 on success and error code otherwise.
+ */
+static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
+                               unsigned long num, unsigned long offset)


+/**
+ * vm_insert_range - insert range of kernel pages starts with non zero offset
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ *
+ * Maps an object consisting of `num' `pages', catering for the user's
+ * requested vm_pgoff
+ *
+ * If we fail to insert any page into the vma, the function will return
+ * immediately leaving any previously inserted pages present.  Callers
+ * from the mmap handler may immediately return the error as their caller
+ * will destroy the vma, removing any successfully inserted pages. Other
+ * callers should make their own arrangements for calling unmap_region().
+ *
+ * Context: Process context. Called by mmap handlers.
+ * Return: 0 on success and error code otherwise.
+ */
+int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
+                               unsigned long num)


+/**
+ * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
+ * @vma: user vma to map to
+ * @pages: pointer to array of source kernel pages
+ * @num: number of pages in page array
+ *
+ * Similar to vm_insert_range(), except that it explicitly sets @vm_pgoff to
+ * 0. This function is intended for the drivers that did not consider
+ * @vm_pgoff.
+ *
+ * Context: Process context. Called by mmap handlers.
+ * Return: 0 on success and error code otherwise.
+ */
+int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
+                               unsigned long num)

