Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7DCAC32750
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 01:36:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6632320842
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 01:36:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="xIgh+scF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6632320842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1D5D6B0005; Tue, 13 Aug 2019 21:36:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECDCA6B0006; Tue, 13 Aug 2019 21:36:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE46B6B0007; Tue, 13 Aug 2019 21:36:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0098.hostedemail.com [216.40.44.98])
	by kanga.kvack.org (Postfix) with ESMTP id BB2F86B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:36:46 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6298D40D6
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 01:36:46 +0000 (UTC)
X-FDA: 75819319212.12.whip78_5822e41276d60
X-HE-Tag: whip78_5822e41276d60
X-Filterd-Recvd-Size: 5712
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 01:36:45 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id f17so43322904otq.4
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 18:36:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=T79FqmE4omVh8KvKRr9Ji1NiYF1jwWoBp2a4S3wYfUE=;
        b=xIgh+scFlFZaMbyoMV1IkOIlX/nYvIEVasdGR+4vgGYHLeiewku5FhfmMF/u82KCRX
         MSErqkN/DgEQsqSvd4X7p+lT0oNexeTRv86qeokYYdUP0BOeLCGjOX9Sd/JWMKEQoS6g
         PwX/lC9BqsULCOBZLAvJixho5nREePWl5uOPg2jE9g0vQx3cZII3Ilx0J7oUMkt8HCC0
         jWbfmfOLvoT/mbKLqBnkK54WVKRXTWevpUb9oXR/7WiAJXekPzezsPzhCgDd3il+q6/O
         WYUwutEc9PedlqPBB8PVWWm7kSFEs6Fj841/WMzEqYowG5ogcen99NisCiTcA9kQF5+G
         eqrQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=T79FqmE4omVh8KvKRr9Ji1NiYF1jwWoBp2a4S3wYfUE=;
        b=VxIMY2FbcgEM2hE1otBpGpY7RAEbyZIrpRVcC5auXVSEhnFRA8pvrfu94UcrkwPexO
         O6s6JOw9v30HplDXVzkxUVrV5qXVmMoOEfefeEQUMwV8vJui3z1x+pw9rgajt3Yhym96
         9f7f+RitRF2VofaL61wCZmpzp38o+RfHZIDiKVjfibivIff3bzV72n4+ee88Q3IR6vla
         AXwUDNbT4GwNcqKSlx6Om9pzzAnPeFud+1DsIxjQBoz3qWOW/IdanayJGOsvb4S15nba
         xK0O9o9o5x1XC1Q7U7QTnLYvWyuQepvkqBBHbSPh0inhF6HCan076nEjItPr4NXPCrWy
         T8Jw==
X-Gm-Message-State: APjAAAU+vnqo4vi+Sh6255kKAMEl6AeZUenAJF6NWfffViRbTGErckT9
	Gm68LzXsFrw5sFm/vv+JFbe22M6jvyMYD0h2xmcPSg==
X-Google-Smtp-Source: APXvYqyFhSP3HBfgQ2MsiomdR7DRqtrfZ8oKVdlDOpd867Al47Dg9XQhd7rDLmPFJUa0Wi698T8sKjV8Y2VXZELxn2I=
X-Received: by 2002:a9d:5f13:: with SMTP id f19mr28233915oti.207.1565746604730;
 Tue, 13 Aug 2019 18:36:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190806160554.14046-1-hch@lst.de> <20190806160554.14046-5-hch@lst.de>
 <20190807174548.GJ1571@mellanox.com> <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com>
 <20190808065933.GA29382@lst.de>
In-Reply-To: <20190808065933.GA29382@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 13 Aug 2019 18:36:33 -0700
Message-ID: <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 7, 2019 at 11:59 PM Christoph Hellwig <hch@lst.de> wrote:
>
> On Wed, Aug 07, 2019 at 11:47:22AM -0700, Dan Williams wrote:
> > > Unrelated to this patch, but what is the point of getting checking
> > > that the pgmap exists for the page and then immediately releasing it?
> > > This code has this pattern in several places.
> > >
> > > It feels racy
> >
> > Agree, not sure what the intent is here. The only other reason call
> > get_dev_pagemap() is to just check in general if the pfn is indeed
> > owned by some ZONE_DEVICE instance, but if the intent is to make sure
> > the device is still attached/enabled that check is invalidated at
> > put_dev_pagemap().
> >
> > If it's the former case, validating ZONE_DEVICE pfns, I imagine we can
> > do something cheaper with a helper that is on the order of the same
> > cost as pfn_valid(). I.e. replace PTE_DEVMAP with a mem_section flag
> > or something similar.
>
> The hmm literally never dereferences the pgmap, so validity checking is
> the only explanation for it.
>
> > > +               /*
> > > +                * We do put_dev_pagemap() here so that we can leverage
> > > +                * get_dev_pagemap() optimization which will not re-take a
> > > +                * reference on a pgmap if we already have one.
> > > +                */
> > > +               if (hmm_vma_walk->pgmap)
> > > +                       put_dev_pagemap(hmm_vma_walk->pgmap);
> > > +
> >
> > Seems ok, but only if the caller is guaranteeing that the range does
> > not span outside of a single pagemap instance. If that guarantee is
> > met why not just have the caller pass in a pinned pagemap? If that
> > guarantee is not met, then I think we're back to your race concern.
>
> It iterates over multiple ptes in a non-huge pmd.  Is there any kind of
> limitations on different pgmap instances inside a pmd?  I can't think
> of one, so this might actually be a bug.

Section alignment constraints somewhat save us here. The only example
I can think of a PMD not containing a uniform pgmap association for
each pte is the case when the pgmap overlaps normal dram, i.e. shares
the same 'struct memory_section' for a given span. Otherwise, distinct
pgmaps arrange to manage their own exclusive sections (and now
subsections as of v5.3). Otherwise the implementation could not
guarantee different mapping lifetimes.

That said, this seems to want a better mechanism to determine "pfn is
ZONE_DEVICE".

