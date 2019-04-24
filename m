Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56043C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 18:08:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B04620652
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 18:08:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="n35r7HLE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B04620652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 991176B0005; Wed, 24 Apr 2019 14:08:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93FC56B0006; Wed, 24 Apr 2019 14:08:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8579C6B0007; Wed, 24 Apr 2019 14:08:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6906B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:08:05 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id w33so1899881otb.23
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 11:08:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8q9yPvjgU1Dmc3BqSRsYFTk9ExzQt5bmVmZcuF82af8=;
        b=d1JHcC4BHLUWq4kroyZbzqFs5MHXXkT5C4jO77y4DdeR218bO3AyIPwDQyWZ2Rgz0t
         uMy3Owugdn4p7dp6ZFyN4YuqbjRtvbT963NyulFm7KM7YOUDUKr6BZJ5L72I/jLcFQXB
         JFxGkJHiJIkeTRuHpIqwdh3C1TSyoFP+h/op2ny8GEjrBYODTw/oeDJrklp9cx27CMq6
         9kHPs6wPgt3161WQWxraONDJsMyN4qpKftvvHjj2pty7QrQFJVQEtfnvmmEbWNQ7TqQA
         CoxzgGjDowtYpixPdrE6OnUqlXNUbL7NUZ8FTVTemhSUk+ah0W+j9v0iTDanU+S0ibCx
         e+mg==
X-Gm-Message-State: APjAAAUXVL63foL3ImOvIRwp1BscSe6396HPfmpxziXE13wOUe07y2Wt
	2flZJZpkGmGV/bmNPTI1b3NQqOnaAC13iXZT+IiyovluLG25qXzgNjWnvrmgTwm2UQsZk9QOYcl
	85F4HSMYlv/GAagXsXP505mnIpWCju3l3Wbmsdd6OsmZTnIyGtyQkmlcNdMJcUHem2w==
X-Received: by 2002:aca:f086:: with SMTP id o128mr228869oih.101.1556129285062;
        Wed, 24 Apr 2019 11:08:05 -0700 (PDT)
X-Received: by 2002:aca:f086:: with SMTP id o128mr228834oih.101.1556129284400;
        Wed, 24 Apr 2019 11:08:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556129284; cv=none;
        d=google.com; s=arc-20160816;
        b=G8UYrCMLsR2J62amqeGF0WrOzuCgN2z2HYfPKjvxJaxYYppANa/WLUTITvqV/P3ElY
         AQklrlTbT+gUNQ2F7SsvYifZ0+hNu8dTPIsoPysuqrji98Nix2twLIFStudsPk/1226i
         99CmammE7cxhpaX7eM5qHiRX+hBbHwoLt6RzCmIfjUF3l2dRLm02TKUQDONPeeT3w1YW
         zHJ9BUOdYWFkHRj+YJpkUdvCE1wawp5/p7WTeo0vbOu7hA0oPTWIgEgUrnF001sGPupZ
         g3GoM1f85h0sVJjvRYfhEmHLyLrX3e55MzvKsmUhHosDA1nv+qNoH9MSbBLm/7r1nxKm
         1w5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8q9yPvjgU1Dmc3BqSRsYFTk9ExzQt5bmVmZcuF82af8=;
        b=shyAygs5Na4mZ5l1hI+7oM8z6D7T4W3Br9yhD3y+tPU7y+P7RSoIIlHu9/+NYt8tu7
         3pFCjAu3ZhO3MdcNv5/ZFyM54Qmu4P7XaozIHueY/r2Tt/1B460SFHtgfWWLxDSOK25m
         CfHFyGK4USp1IZTVE9YAnJJdbZpiIyW1UYNY+1puXHPxw+3tPoyUmzS9eWeSNXxLxxkC
         c36Wc2K/01rCg5zxYX7NarRQ2XMXSQ6hFgzFnBGN4OLdG5vKwYpeuoHZT7ZSTqnhkLPp
         Q5DBa4YdrX7llwl1pEe175vTwoTpHrYzYaoA99j6WVavCQclLi6jOz4/DkjMF6Cuz6uE
         qG5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=n35r7HLE;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h11sor8559813oib.114.2019.04.24.11.08.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 11:08:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=n35r7HLE;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8q9yPvjgU1Dmc3BqSRsYFTk9ExzQt5bmVmZcuF82af8=;
        b=n35r7HLELoguC4+CDnNmcyHD93QJUumktU3TTYTT85K1K93kZndcMpl7JZesyoPmNR
         jExL9hZ2+RXj4TANemwSx12DYO6BcMPdE5APBpgYQAQodtB0+JR+vmO82L0DVaUiA6Qo
         quxRikkZsR9RQUFUFtxbtBnY+a1yYn2QZqOnZ4yPEh2uZl2+Bl3jQihIzoRRIP2TqP3O
         WY3tx1QeXl1tl8V14appaRj2bC+66o204Bey5C/7QXCdJJv7BONvI7a+8z8BLSVRI4oB
         T8P5fgoJKdXi2KNELRKXOGkWm5p5MiNBceHQv5mw5z2c4ID9RPWjLk0oy43G3O5Q+zNz
         zG7w==
X-Google-Smtp-Source: APXvYqwUscsee1H3tWh0LwutS4rgxqlReQCcuMcrIVSy6LAXYPTW+nyIjR2WiohPRoNbvVXrkWOUWHNWNhknw/nsrb8=
X-Received: by 2002:aca:b108:: with SMTP id a8mr297824oif.0.1556129283720;
 Wed, 24 Apr 2019 11:08:03 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552636696.2015392.12612320706815016081.stgit@dwillia2-desk3.amr.corp.intel.com>
 <3dda9d08-a572-65b9-2f2f-da978a008deb@redhat.com>
In-Reply-To: <3dda9d08-a572-65b9-2f2f-da978a008deb@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Apr 2019 11:07:52 -0700
Message-ID: <CAPcyv4imzm5reh7d-p4Xyt=Sdoi5WDFC6t9FgLaZVexbWfGG5Q@mail.gmail.com>
Subject: Re: [PATCH v6 06/12] mm/hotplug: Add mem-hotplug restrictions for remove_memory()
To: David Hildenbrand <david@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 2:21 PM David Hildenbrand <david@redhat.com> wrote:
>
> On 17.04.19 20:39, Dan Williams wrote:
> > Teach the arch_remove_memory() path to consult the same 'struct
> > mhp_restrictions' context as was specified at arch_add_memory() time.
> >
> > No functional change, this is a preparation step for teaching
> > __remove_pages() about how and when to allow sub-section hot-remove, and
> > a cleanup for an unnecessary "is_dev_zone()" special case.
>
> I am not yet sure if this is the right thing to do. When adding memory,
> we obviously have to specify the "how". When removing memory, we usually
> should be able to look such stuff up.

True, the implementation can just use find_memory_block(), and no need
to plumb this flag.

>
>
> >  void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> > -                 unsigned long nr_pages, struct vmem_altmap *altmap)
> > +             unsigned long nr_pages, struct mhp_restrictions *restrictions)
> >  {
> >       unsigned long i;
> > -     unsigned long map_offset = 0;
> >       int sections_to_remove;
> > +     unsigned long map_offset = 0;
> > +     struct vmem_altmap *altmap = restrictions->altmap;
> >
> > -     /* In the ZONE_DEVICE case device driver owns the memory region */
> > -     if (is_dev_zone(zone)) {
> > -             if (altmap)
> > -                     map_offset = vmem_altmap_offset(altmap);
> > -     }
> > +     if (altmap)
> > +             map_offset = vmem_altmap_offset(altmap);
> >
>
> Why weren't we able to use this exact same hunk before? (after my
> resource deletion cleanup of course)
>
> IOW, do we really need struct mhp_restrictions here?

We don't need it. It was only the memblock info why I added the
"restrictions" argument.

> After I factor out memory device handling into the caller of
> arch_remove_memory(), also the next patch ("mm/sparsemem: Prepare for
> sub-section ranges") should no longer need it. Or am I missing something?

That patch is still needed for the places where it adds the @nr_pages
argument, but the mhp_restrictions related bits can be dropped. The
subsection_check() helper needs to be refactored a bit to not rely on
mhp_restrictions.

