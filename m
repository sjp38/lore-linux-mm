Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1B57C04AAA
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:03:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53421206DF
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:03:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="NXrhseMI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53421206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D25DF6B0003; Thu,  2 May 2019 10:03:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD73E6B0006; Thu,  2 May 2019 10:03:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9F476B0007; Thu,  2 May 2019 10:03:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 919CD6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 10:03:58 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id f21so1165744oib.21
        for <linux-mm@kvack.org>; Thu, 02 May 2019 07:03:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Euj/oOqbk9HuxRwDBjqia2Fr0aJCycnpu+F/zXaFzrk=;
        b=LXgOO+LBayqoLdyEUl96x7HTrKq4Yf4OldtfaeLQQygdyTVfS84vlADsXHLFAM0n7H
         fuX+vergC+ZqwhT8ea3/Vm8v3xydulC+aW7lrZlUpAz72a8Efg9afD9SAfp5qH+dqYpY
         RL8Bpr290+L43TQCJmamwlQgN0f4XLcBcPzJWaXPlAO3i1T2DBub+O24HWEeO2cZO3Yf
         JhjtParjr94syXIhoD4/p+6We42H84m5tdIIGfCryPeVQaDHq3BDAxgFb2U5/ybut/kf
         9g7mqZ4UHNoYoOk0mKG3EaPICHpTlo/jPIPCNdySdRdqw+TIPPPFnKyEx6YuJofbdfbj
         NeEg==
X-Gm-Message-State: APjAAAXK/6HnYb4Mu25H8kx2t+7fl+C8/Y8JTvJTJxcfZUx7R0nTJwZr
	s9ZZyvpykhgWFMmk5TncMVOiP+in4aDL5dv2cgxogNWeTjMJDb2mu8Z71YDN4s84NOviCYS7Ubk
	RGXtXYhCKOZqjpvW/hlL8/uP389PUWulLZPCt1X2myLf/fHAE+xDVeMMe1tig1NmwbA==
X-Received: by 2002:a9d:4909:: with SMTP id e9mr2604668otf.160.1556805837854;
        Thu, 02 May 2019 07:03:57 -0700 (PDT)
X-Received: by 2002:a9d:4909:: with SMTP id e9mr2604531otf.160.1556805836144;
        Thu, 02 May 2019 07:03:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556805836; cv=none;
        d=google.com; s=arc-20160816;
        b=FyaxEPNzjgSee9szL6I7tXouFoMDExDaMfIFH/r9Jg74+JKx2n7w/uNB0i3HaK0zZh
         aPmqJXnQ32+kEDxyTFhbWhDEGqvPgptyiUZMb2LySwLCRtnElIB8v5ACL9Kb/AWnxVzN
         wkk/McjCoKrUtgz4rgASBAa3DaWh0UvG7nhbth6eDpOwIKuK6XPwnZJ66ZP0aHWLs+PG
         aBjV4c33zsafI/FVhRDN+AvVSFabRwGsZSGac5lB2v8NFm+n6/keRZaDMo1ARcyHVOh4
         xc5rIOYninoglrahNBDeC49f8if5X4LZt64uLpS5GzFxuHNfbuD/pMTQtximgFsxiAS0
         /s/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Euj/oOqbk9HuxRwDBjqia2Fr0aJCycnpu+F/zXaFzrk=;
        b=kuUlIG3Gc0R/TtKBhICZCvNL2NYQrQLCuFnlMHn0QElbDXNNm/bicpc7i/mjmQA4yv
         c2PsF7K9eviCO0vv2Ycb6UZJ8Cv1aVx0GPHiYTg5lz4Fm46w+UXTpXH87PXhs34CrUyN
         0584B+SRC8iUth11dQW+TIJUKuAcTNkny9namgYqlAmCLVR1e9B2IXYVeoJA6CRq9TNo
         BCfCmwISRtKhJjz9QGV8w0W9kAekxvItyG/rBlOl5y0JRNCaj02Ln/PhRb8fBlH6sDzQ
         DQhoHIiNFifyUDM+w0PNCbCMMMWiWUthMBF3G3vJetwbcmxQmpBQQ0nl5NtPLUxK6XIx
         UKtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=NXrhseMI;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u9sor19488578otb.49.2019.05.02.07.03.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 07:03:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=NXrhseMI;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Euj/oOqbk9HuxRwDBjqia2Fr0aJCycnpu+F/zXaFzrk=;
        b=NXrhseMIXgWPGIFhlyc9Z/V4XXm1FlHayGm9On9S2QTFx1WGXViWNUmeSC1crrBq/9
         9KH14pIGNUqvbPv6FRwdD9xzBoryGcD0XT5mc3ccb3Ch4tlYtDOFtjEw8X0eeKOTlW7X
         2eu90LpR4ryOOpxkPlWd5XKCh8alHeMP5WhrZgm4q49tG60hm64olKpHPL/lkjB7aQj7
         GWkToFdWhjFK6F7I90cr69Vt4f8asXc+UbvPJWC9B827dUaKj3O0Zi4Eojxm+mkwC4qs
         /61HOWmpEQOWXvVZIQjNDilixOOdf5PWS3fV5m9RZ6UCYzU5Zx4qxlDKH7BJPXpudCpI
         geyg==
X-Google-Smtp-Source: APXvYqweuc2pQKNZE3EnaRW+bSeokBQ4JRwB71yyAF/tr2iarU5tGWhqAgHvmoE0NT4f1XcWY0zKcbOKL4pbCPmXjHM=
X-Received: by 2002:a9d:7ad1:: with SMTP id m17mr1629780otn.367.1556805835280;
 Thu, 02 May 2019 07:03:55 -0700 (PDT)
MIME-Version: 1.0
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677653785.2336373.11131100812252340469.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190502074803.GA3495@linux>
In-Reply-To: <20190502074803.GA3495@linux>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 2 May 2019 07:03:45 -0700
Message-ID: <CAPcyv4jPG56sf4hHaKEoacQbDEpcMrr4fJVEwkxGjcWcCmieNQ@mail.gmail.com>
Subject: Re: [PATCH v7 03/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
To: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Jane Chu <jane.chu@oracle.com>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 2, 2019 at 12:48 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> On Wed, May 01, 2019 at 10:55:37PM -0700, Dan Williams wrote:
> > Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> > section active bitmask, each bit representing 2MB (SECTION_SIZE (128M) /
> > map_active bitmask length (64)). If it turns out that 2MB is too large
> > of an active tracking granularity it is trivial to increase the size of
> > the map_active bitmap.
> >
> > The implications of a partially populated section is that pfn_valid()
> > needs to go beyond a valid_section() check and read the sub-section
> > active ranges from the bitmask.
> >
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Tested-by: Jane Chu <jane.chu@oracle.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Unfortunately I did not hear back about the comments/questions I made for this
> in the previous version.

Apologies, yes, will incorporate.

>
> > ---
> >  include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
> >  mm/page_alloc.c        |    4 +++-
> >  mm/sparse.c            |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 79 insertions(+), 2 deletions(-)
> >
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 6726fc175b51..cffde898e345 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -1175,6 +1175,8 @@ struct mem_section_usage {
> >       unsigned long pageblock_flags[0];
> >  };
> >
> > +void section_active_init(unsigned long pfn, unsigned long nr_pages);
> > +
> >  struct page;
> >  struct page_ext;
> >  struct mem_section {
> > @@ -1312,12 +1314,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
> >
> >  extern int __highest_present_section_nr;
> >
> > +static inline int section_active_index(phys_addr_t phys)
> > +{
> > +     return (phys & ~(PA_SECTION_MASK)) / SECTION_ACTIVE_SIZE;
> > +}
> > +
> > +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> > +static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
> > +{
> > +     int idx = section_active_index(PFN_PHYS(pfn));
> > +
> > +     return !!(ms->usage->map_active & (1UL << idx));
>
> section_active_mask() also converts the value to address/size.
> Why do we need to convert the values and we cannot work with pfn/pages instead?
> It should be perfectly possible unless I am missing something.
>
> The only thing required would be to export earlier your:
>
> +#define PAGES_PER_SUB_SECTION (SECTION_ACTIVE_SIZE / PAGE_SIZE)
> +#define PAGE_SUB_SECTION_MASK (~(PAGES_PER_SUB_SECTION-1))
>
> and change section_active_index to:
>
> static inline int section_active_index(unsigned long pfn)
> {
>         return (pfn & ~(PAGE_SECTION_MASK)) / SUB_SECTION_ACTIVE_PAGES;
> }
>
> In this way we do need to shift the values every time and we can work with them
> directly.
> Maybe you made it work this way because a reason I am missing.
>
> > +static unsigned long section_active_mask(unsigned long pfn,
> > +             unsigned long nr_pages)
> > +{
> > +     int idx_start, idx_size;
> > +     phys_addr_t start, size;
> > +
> > +     if (!nr_pages)
> > +             return 0;
> > +
> > +     start = PFN_PHYS(pfn);
> > +     size = PFN_PHYS(min(nr_pages, PAGES_PER_SECTION
> > +                             - (pfn & ~PAGE_SECTION_MASK)));
>
> It seems to me that we already picked the lowest value back in
> section_active_init, so we should be fine if we drop the min() here?
>
> Another thing is why do we need to convert the values to address/size, and we
> cannot work with pfns/pages.
> Unless I am missing something it should be possible.

Right, I believe the physical address conversion was a holdover from a
previous version and these helpers can be cleaned up to be pfn based,
good catch.

>
> > +     size = ALIGN(size, SECTION_ACTIVE_SIZE);
> > +
> > +     idx_start = section_active_index(start);
> > +     idx_size = section_active_index(size);
> > +
> > +     if (idx_size == 0)
> > +             return -1;
>
> Maybe we would be better off converting that -1 into something like "FULL_SECTION",
> or at least dropping a comment there that "-1" means that the section is fully
> populated.

Agreed, I'll add a #define.

Thanks Oscar.

