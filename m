Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36D8BC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:55:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E36082089E
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:55:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="xH/dL+8B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E36082089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69D2B6B0275; Thu, 15 Aug 2019 15:55:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64DEF6B0277; Thu, 15 Aug 2019 15:55:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53BFF6B027A; Thu, 15 Aug 2019 15:55:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0059.hostedemail.com [216.40.44.59])
	by kanga.kvack.org (Postfix) with ESMTP id 2C38F6B0275
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:55:05 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id DC8BE180AD7C1
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:55:04 +0000 (UTC)
X-FDA: 75825715728.16.frame01_8393c1979f352
X-HE-Tag: frame01_8393c1979f352
X-Filterd-Recvd-Size: 6536
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:55:04 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id z17so7445397otk.13
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:55:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LCurvHSsCmm+5abpD1hHi8j9syc25zepop2mZHAT1y4=;
        b=xH/dL+8B9O/zZKNIOGU6AfrXiRnIVSoM/QVzh3O/W1WrG7+QJ7zdE55DiVebnalEgC
         vTxenCv0UyCxprQskHOjZCNfO9tDnSYNYjShnRS9S8nGbAi9K84dtTK4SykQnUUY+Wfn
         QYXMsvN2m1hOdgmNxAYop02NE9UNOSHmPgM9ocDDtHoNY6B8efMYhaN+FmvESxReiDvM
         L1lyGAAsi9JZGdXWde0N9P1FrA9q6ON7cqyl6tq+dy8zpwgbVsCGO4Vmb+r6fawX2sxI
         P2VJvzDwvclquW9A7/qiiyfsNrlhpbYRN5DB7Z0t3gx+ZoBCEHi5lhlksGs8G4lvW7F9
         irfg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=LCurvHSsCmm+5abpD1hHi8j9syc25zepop2mZHAT1y4=;
        b=N4toQ9T5SsBmTWU30lxURrIE9IxRyDUBjXVJxFfbG0XdgqiOQzypeYnGggL1l89FlC
         xBiqpsmf8X4sMf9TMFOuIchKTQCKxZ8tMBD2Kx/8nx8+zjrTt4TaYfy0wupXcRYY+4ux
         OfMFYfLbowCrYG8uNa7xTT+uW2u6UBtR6H6S8IfcbgnDmYVADaq1qxHHHZzhFu2rK/X5
         +9cbPYNZpvphcwjoSNoyRleOtX4C3E2trRU3Fr5pmdo59I5JYySdMvkdDkzlqq707MSC
         bhj7bIglD2zwYHCA2/AAVOmisaeBNU0Ft4VlAGBihsg9Bao5TXhOO6oBS4rPPiy0i3sN
         azHw==
X-Gm-Message-State: APjAAAXX6C1CK8e/KTkLeEVhUlMje5Icj2yBGP4zOq6Xq+TRko7yc18X
	D/4hLcX+GFyBDHdofEHEepITKnTBJbO38NauZ6XNHA==
X-Google-Smtp-Source: APXvYqy1liZCgiuHpWjdJNheD/dz2N3XqsT5VgT3WadMNktE9u2Z8H3IIyr8WcBpt7CM+JZCn80RNisRK5YpkWEdAgY=
X-Received: by 2002:a05:6830:458:: with SMTP id d24mr4558154otc.126.1565898903272;
 Thu, 15 Aug 2019 12:55:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190809074520.27115-1-aneesh.kumar@linux.ibm.com>
 <20190809074520.27115-2-aneesh.kumar@linux.ibm.com> <CAPcyv4jmxKPkTh0_Bbu2tRXm4vcBHonZJ6UcKrOBnPGCG2_i1A@mail.gmail.com>
In-Reply-To: <CAPcyv4jmxKPkTh0_Bbu2tRXm4vcBHonZJ6UcKrOBnPGCG2_i1A@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 15 Aug 2019 12:54:51 -0700
Message-ID: <CAPcyv4hxo4HvtqZ-B6JG5iATo_vEAKPzO5EU5Lugs2_edEbW7Q@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] nvdimm: Consider probe return -EOPNOTSUPP as success
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 9:22 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Hi Aneesh, logic looks correct but there are some cleanups I'd like to
> see and a lead-in patch that I attached.
>
> I've started prefixing nvdimm patches with:
>
>     libnvdimm/$component:
>
> ...since this patch mostly impacts the pmem driver lets prefix it
> "libnvdimm/pmem: "
>
> On Fri, Aug 9, 2019 at 12:45 AM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
> >
> > This patch add -EOPNOTSUPP as return from probe callback to
>
> s/This patch add/Add/
>
> No need to say "this patch" it's obviously a patch.
>
> > indicate we were not able to initialize a namespace due to pfn superblock
> > feature/version mismatch. We want to consider this a probe success so that
> > we can create new namesapce seed and there by avoid marking the failed
> > namespace as the seed namespace.
>
> Please replace usage of "we" with the exact agent involved as which
> "we" is being referred to gets confusing for the reader.
>
> i.e. "indicate that the pmem driver was not..." "The nvdimm core wants
> to consider this...".
>
> >
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> > ---
> >  drivers/nvdimm/bus.c  |  2 +-
> >  drivers/nvdimm/pmem.c | 26 ++++++++++++++++++++++----
> >  2 files changed, 23 insertions(+), 5 deletions(-)
> >
> > diff --git a/drivers/nvdimm/bus.c b/drivers/nvdimm/bus.c
> > index 798c5c4aea9c..16c35e6446a7 100644
> > --- a/drivers/nvdimm/bus.c
> > +++ b/drivers/nvdimm/bus.c
> > @@ -95,7 +95,7 @@ static int nvdimm_bus_probe(struct device *dev)
> >         rc = nd_drv->probe(dev);
> >         debug_nvdimm_unlock(dev);
> >
> > -       if (rc == 0)
> > +       if (rc == 0 || rc == -EOPNOTSUPP)
> >                 nd_region_probe_success(nvdimm_bus, dev);
>
> This now makes the nd_region_probe_success() helper obviously misnamed
> since it now wants to take actions on non-probe success. I attached a
> lead-in cleanup that you can pull into your series that renames that
> routine to nd_region_advance_seeds().
>
> When you rebase this needs a comment about why EOPNOTSUPP has special handling.
>
> >         else
> >                 nd_region_disable(nvdimm_bus, dev);
> > diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> > index 4c121dd03dd9..3f498881dd28 100644
> > --- a/drivers/nvdimm/pmem.c
> > +++ b/drivers/nvdimm/pmem.c
> > @@ -490,6 +490,7 @@ static int pmem_attach_disk(struct device *dev,
> >
> >  static int nd_pmem_probe(struct device *dev)
> >  {
> > +       int ret;
> >         struct nd_namespace_common *ndns;
> >
> >         ndns = nvdimm_namespace_common_probe(dev);
> > @@ -505,12 +506,29 @@ static int nd_pmem_probe(struct device *dev)
> >         if (is_nd_pfn(dev))
> >                 return pmem_attach_disk(dev, ndns);
> >
> > -       /* if we find a valid info-block we'll come back as that personality */
> > -       if (nd_btt_probe(dev, ndns) == 0 || nd_pfn_probe(dev, ndns) == 0
> > -                       || nd_dax_probe(dev, ndns) == 0)
>
> Similar need for an updated comment here to explain the special
> translation of error codes.
>
> > +       ret = nd_btt_probe(dev, ndns);
> > +       if (ret == 0)
> >                 return -ENXIO;
> > +       else if (ret == -EOPNOTSUPP)
>
> Are there cases where the btt driver needs to return EOPNOTSUPP? I'd
> otherwise like to keep this special casing constrained to the pfn /
> dax info block cases.

In fact I think EOPNOTSUPP is only something that the device-dax case
would be concerned with because that's the only interface that
attempts to guarantee a given mapping granularity.

