Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5745C04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 20:58:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C98220B7C
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 20:58:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="qmbcluUn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C98220B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6AA46B000A; Tue,  7 May 2019 16:58:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1AF56B000C; Tue,  7 May 2019 16:58:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C09A26B000D; Tue,  7 May 2019 16:58:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 933986B000A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 16:58:05 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id g80so345293otg.12
        for <linux-mm@kvack.org>; Tue, 07 May 2019 13:58:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1mkmD4Z4DaLqsFVMxyizn2ogd6gC2HtEG84lOnN4epw=;
        b=Ps5UTS8jdd0hOqe4tsJOK21UprvSbxEP5LVHXfzRtzISfdpOszrc9b05lh7QsPlo1V
         d2sEkfK3565bO/wWBWa7oe2jPm1w5tQzfMJHUBCWBIxtIZB36kI4q6RDmKzRZhNZlFv8
         Re7zijs6MXKVW1x1XA0a/PAa/C4IOwRDMBsVpSbiCuL7Vv53zw4xIVO6xD+Vb7y5J+eo
         j68todxL3HPebfyzUlJLZqC2l1fSFF3kfKTzHDTsE3Vv1/d2LqeBWJkW0DUUXfAcr0ay
         J/f1wZ87vTXS/OWF1aDxglZbnztcsh7B1FM+E2DWwTUDslwc3ReXDZXDqzAkoy6zDIEC
         ng1A==
X-Gm-Message-State: APjAAAUuDgKwmJ/Ru0hOjchQWBitN2HaTKhR4WbK8V6MezMHj85gTRAl
	mbc5MLojmPwgtCBxShTcDs9oflLSkV4g5piK8x9UAFxpkRPV8grScn8bwtbNBkJbHobRRwGp8JD
	6dN+eb4k7iJuH6eImx8mmHIqMYXkgyw1VB0CIH844oTEGL8szOvF+eZMwtVimU6Hd3Q==
X-Received: by 2002:a9d:6344:: with SMTP id y4mr7256206otk.11.1557262685285;
        Tue, 07 May 2019 13:58:05 -0700 (PDT)
X-Received: by 2002:a9d:6344:: with SMTP id y4mr7256169otk.11.1557262684588;
        Tue, 07 May 2019 13:58:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557262684; cv=none;
        d=google.com; s=arc-20160816;
        b=x+sswAPQyidEXlCl3fv2XHH2T02bn+wCsjH/fsmrKtw1qftmhBKnDr6R9FigbEi+y3
         Kvy7ybkVKGFvdZpATr6N+p6X+JPq8eo14YWlU/ZDUovNJBmPGGXtT7zArA6AteeBhq7E
         HX0eWaEDu+fTJayB5pF/Dr/+eyIs47OQxY6blE41LSgISvBxKYmnP0mzavKGIbhB3fWe
         gGFByo7nOZw2XJzT2nV50/cUB/ykbD8K48EUQ5xaswBc4GFYV+sfWDENqoku7VNtkIWW
         +6+18kq8MkcyLucXuNibBaKo4vYCEcEdM934ht69D68YDWelWRwjVXrJAas64a7059c4
         1AkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1mkmD4Z4DaLqsFVMxyizn2ogd6gC2HtEG84lOnN4epw=;
        b=lAgZ9mhXeyiqCPhymEcUfNoqLJqSFwrkCnPBeq6R/I0ZlyQQmO/iJaFh98EgFEwa0c
         SVfbu8ux0oa4pYIXqW1K+HkBWwGRU8ALahIf8d30HTVu1f/A6A/i2ap7WIgyeP5xoJ0j
         5eZzi9qXSyS9OUsT/+8EbhUg3KwcgWQE5AvC2aIk3Bas3wMUdzZ6+y+0Tj0B5upsLNIK
         ZPzssJUGbx6A5anhsbZ46qkhs4G1XT8mgp/5wkRNauvk2b5wXLhLJXudJWByfcTBOimW
         e/7eM8XAqEVJdmRaBWm2h/mzsbq3+oScjcqIYe/OIHvPmW41kDKQ/6lZC070kP6/aCOo
         vWnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qmbcluUn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m188sor3663635oib.12.2019.05.07.13.58.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 13:58:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qmbcluUn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1mkmD4Z4DaLqsFVMxyizn2ogd6gC2HtEG84lOnN4epw=;
        b=qmbcluUnRpOQqSYRBKyovFsqnRyKdZV6CKWDoAJpSXQgJX7TkK70etljQyZyVQQnWK
         c/TZ+swgI53npSGuu+2JE/6bhNbaKy50WoMbrLuYyKHZOgqRoVScpSt0AHUDQRiAcQzX
         oCyb7TNqVt24+RL0Vtf6NVC5n0CHu3+rUn0PpLS9pEtxDWSdjTEzY+2ThOkn98GdTmda
         WmIbbUjijC2Xp4qKF6wR2l25YLIsQ8YxWCiZOFzDQPqyWI7L+PornZQly/H7EWMuQpgU
         mqhMDZu6CDJUg4UY9KVxC9TDUrtrrctwMCXZWKSFyTMkz/OdmaK1KBlJJy5VFIuOBhbY
         bP+g==
X-Google-Smtp-Source: APXvYqzD5+iPmR82mW0JcgXC+OAUQI8mo10rE9WLLRa7cfVMYW4IBqbIoZo+d7Cn/arRPuEVXDJreevhDqywHe+Kspk=
X-Received: by 2002:aca:b108:: with SMTP id a8mr333966oif.0.1557262684029;
 Tue, 07 May 2019 13:58:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-3-david@redhat.com>
 <CAPcyv4gtAMn2mDz0s1GRTJ52MeTK3jJYLQne6MiEx_ipPFUsmA@mail.gmail.com> <97a6a2ab-0e8b-d403-ca39-ffa4425e15a5@redhat.com>
In-Reply-To: <97a6a2ab-0e8b-d403-ca39-ffa4425e15a5@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 13:57:53 -0700
Message-ID: <CAPcyv4hvpBo=6c6pFCoGiEf3xiPsjc8w2p4Y6_bW4PrzcN=Few@mail.gmail.com>
Subject: Re: [PATCH v2 2/8] s390x/mm: Implement arch_remove_memory()
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Vasily Gorbik <gor@linux.ibm.com>, Oscar Salvador <osalvador@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 1:47 PM David Hildenbrand <david@redhat.com> wrote:
>
> On 07.05.19 22:46, Dan Williams wrote:
> > On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
> >>
> >> Will come in handy when wanting to handle errors after
> >> arch_add_memory().
> >>
> >> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> >> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> Cc: Michal Hocko <mhocko@suse.com>
> >> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> >> Cc: David Hildenbrand <david@redhat.com>
> >> Cc: Vasily Gorbik <gor@linux.ibm.com>
> >> Cc: Oscar Salvador <osalvador@suse.com>
> >> Signed-off-by: David Hildenbrand <david@redhat.com>
> >> ---
> >>  arch/s390/mm/init.c | 13 +++++++------
> >>  1 file changed, 7 insertions(+), 6 deletions(-)
> >>
> >> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> >> index 31b1071315d7..1e0cbae69f12 100644
> >> --- a/arch/s390/mm/init.c
> >> +++ b/arch/s390/mm/init.c
> >> @@ -237,12 +237,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
> >>  void arch_remove_memory(int nid, u64 start, u64 size,
> >>                         struct vmem_altmap *altmap)
> >>  {
> >> -       /*
> >> -        * There is no hardware or firmware interface which could trigger a
> >> -        * hot memory remove on s390. So there is nothing that needs to be
> >> -        * implemented.
> >> -        */
> >> -       BUG();
> >> +       unsigned long start_pfn = start >> PAGE_SHIFT;
> >> +       unsigned long nr_pages = size >> PAGE_SHIFT;
> >> +       struct zone *zone;
> >> +
> >> +       zone = page_zone(pfn_to_page(start_pfn));
> >
> > Does s390 actually support passing in an altmap? If 'yes', I think it
> > also needs the vmem_altmap_offset() fixup like x86-64:
> >
> >         /* With altmap the first mapped page is offset from @start */
> >         if (altmap)
> >                 page += vmem_altmap_offset(altmap);
> >
> > ...but I suspect it does not support altmap since
> > arch/s390/mm/vmem.c::vmemmap_populate() does not arrange for 'struct
> > page' capacity to be allocated out of an altmap defined page pool.
> >
> > I think it would be enough to disallow any arch_add_memory() on s390
> > where @altmap is non-NULL. At least until s390 gains ZONE_DEVICE
> > support and can enable the pmem use case.
> >
>
> As far as I know, it doesn't yet, however I guess this could change once
> virtio-pmem is supported?

I would expect and request virtio-pmem remain a non-starter on s390
until s390 gains ZONE_DEVICE support. As it stands virtio-pmem is just
another flavor of the general pmem driver and the pmem driver
currently only exports ZONE_DEVICE pfns tagged by the PTE_DEVMAP
pte-flag and PFN_DEV+PFN_MAP pfn_t-flags.

A hamstrung version of DAX (CONFIG_FS_DAX_LIMITED) is enabled for the
s390/dcssblk driver, but that requires that the driver indicate this
limited use case via the PTE_SPECIAL pte-flag and PFN_SPECIAL
pfn_t-flag. I otherwise do not want to see CONFIG_FS_DAX_LIMITED
spread outside of the s390/dcssblk use case.

