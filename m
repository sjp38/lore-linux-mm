Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AE11C43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 12:57:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 226132063F
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 12:57:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Q1s+yLF0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 226132063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8F3F6B0006; Fri,  3 May 2019 08:57:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B402D6B0008; Fri,  3 May 2019 08:57:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A557C6B000A; Fri,  3 May 2019 08:57:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 559806B0006
	for <linux-mm@kvack.org>; Fri,  3 May 2019 08:57:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e21so3666951edr.18
        for <linux-mm@kvack.org>; Fri, 03 May 2019 05:57:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=VaxPQ6IeVmYMFGePLBrY6yLBQaxZgQlHXQuFLzQ/+d4=;
        b=eadL8xkXoFi2v96G/+TzmnJGpPrZaVMWEUE00XLiB1sln1rVecEdJ1JIS590YIG7p8
         soHgTdhw7V8Wicvl0UIXhunGQLEqo6V17SE/IveQGXJwZ3qwWYUbzjQPaUiE7DEQrFby
         uYAuce/nBTRXLaViNDZsFCuvmt9++9Rjv9jFjw5sGWagcjQVDBT01dtCzYUHedIjRP2r
         HxDNFrCBxy6DM4Zu5WOs89EBGKTW3reThatBMbngXuWx69BH22TadOuDzISkAlwqS0mg
         DNNrC7jhLgDvpgEEISWHEjXBRDasD6pXyqutkx+waoWAXou/gC605TQFSdrJZHA9j0lD
         aXSQ==
X-Gm-Message-State: APjAAAV/QZxH3rt1RjuKeBRBOPplWe0nMQXwnmIFubNlBdn/qUlvd1f3
	+bhrZxi3zqbSa0ijN8+Fw6cpr8VCEbeQ06KxZjsZ1mzpHbrbuXWt8qaRXuUB8RsQFxuT9trPqTI
	0bvaZg237hgPwN8udZAj7cw85NjoS3l0o+1B5+SwVlZiXwtfCkPYRoD/13vmawNuOOA==
X-Received: by 2002:a50:cb4d:: with SMTP id h13mr8305631edi.110.1556888241927;
        Fri, 03 May 2019 05:57:21 -0700 (PDT)
X-Received: by 2002:a50:cb4d:: with SMTP id h13mr8305550edi.110.1556888241021;
        Fri, 03 May 2019 05:57:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556888241; cv=none;
        d=google.com; s=arc-20160816;
        b=xwg7Y+4hqhjJ2gGqsP0eLG88avRRia6unQoKPvNUJ9XzIZ18KNC6isKSDF4JqyT6+Q
         82juG+tryr4ftHIb4UD5on6vNcUCiKuBxCGQcvgMEeaaDqZXGZ/Z+tnZAFcQuNhwpgrV
         W/8byVyiO6oBckErr+mLJUR8pwOSub3p5lDdrNYV1gYYd4chIdGqkF3AscaH5o+P0lUT
         HYwZcXikgaHj5wQGwB0MK7LGwh8I9PGfd6GnZIXCJT4YkQvUi/M0ueJzLYMf7Lacf2wX
         J0AyzJGrux7TiGeCHbgFzOL13Y0IaxLMwQ6bCxezlF9zylk7OYym5EzXkeolN2iNr1M8
         GfJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=VaxPQ6IeVmYMFGePLBrY6yLBQaxZgQlHXQuFLzQ/+d4=;
        b=aS+kFboLCz/5qSLv4eq7Mq1sytk2f5jmrk4/jbvW3dpBEzZSPnKHxGcbl+Mlg5mOaC
         G4NsfmyQHq0r2YJsp/EQ3L98F2qgOt6a+9ekPYoqO225DSFWQjdD11cjHcJWsnoqTBE0
         NY28Yd55We9iV1G5DfYXI5N5hPzNdfU/I1doWpHcdYUeiZHLUulLmmhgF8y3enCdVEcI
         yPMuoEd79Zyu7llB35gCBEXGiW5+3M7NAFv00EUmVPTy/239SR5ZiAD5Z/DLMXqnXCR6
         fbfsyeOxt6+/yB0OJY+p4r8kSWkApamfs+9FF0coKwwB8gOY6ztUV/za0Wephqnzf7CZ
         vYSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Q1s+yLF0;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d16sor1755671edj.5.2019.05.03.05.57.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 May 2019 05:57:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Q1s+yLF0;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=VaxPQ6IeVmYMFGePLBrY6yLBQaxZgQlHXQuFLzQ/+d4=;
        b=Q1s+yLF06i2mWw5XUZDrN3OrhZkHA8MeRl3UBfwzVL1qD0zqGe2QutTZhtxhQAoE9D
         xvQ5wXPYNODkqxiQUF3mOTp7pZE9B7BCM+r90yRx6rXkZ45fnVut3oNIknNMHV9McNkz
         gnPbaALBFQupBUtkVTqzWtVenkPE2fscTIKqyRkAgsETnrM+I6zEsxcVGWz+wqVSLltU
         /EYGqnwmMsMHGuJW2fhPE0vGgNHR0K9Q8kz4UKmPnoynnLJRvhF0Cch3nRtebAg2LxL7
         sWpRPHoR6w4Xyl/FMtZRKVQr4qwfszDvBPp+SUx3ktr5jhhURApDYJ2I0IcQGnJaUENr
         hK5A==
X-Google-Smtp-Source: APXvYqxGpxdtpUzePQzoj8+ABR2xl3yPHLROkt/fFrbcMScpdOGg5GoJBHZkg6V088MaY7vMf4/rxnhdCFk/G/55mD8=
X-Received: by 2002:a50:b56a:: with SMTP id z39mr8130377edd.91.1556888240692;
 Fri, 03 May 2019 05:57:20 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552634586.2015392.2662168839054356692.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CA+CK2bCkqLc82G2MW+rYrKTi4KafC+tLCASkaT8zRfVJCCe8HQ@mail.gmail.com>
 <CAPcyv4g+KNu=upejy7Xm=jWR0cdhygPAdSRbkfFGpJeHFGc4+w@mail.gmail.com> <bd76cb2f-7cdc-f11b-11ec-285862db66f3@arm.com>
In-Reply-To: <bd76cb2f-7cdc-f11b-11ec-285862db66f3@arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 3 May 2019 08:57:09 -0400
Message-ID: <CA+CK2bBS5Csz0O9sDVwt_NjtrBtLaMfkycjhaOmR7mXoKJ5XEg@mail.gmail.com>
Subject: Re: [PATCH v6 02/12] mm/sparsemem: Introduce common definitions for
 the size and mask of a section
To: Robin Murphy <robin.murphy@arm.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 3, 2019 at 6:35 AM Robin Murphy <robin.murphy@arm.com> wrote:
>
> On 03/05/2019 01:41, Dan Williams wrote:
> > On Thu, May 2, 2019 at 7:53 AM Pavel Tatashin <pasha.tatashin@soleen.co=
m> wrote:
> >>
> >> On Wed, Apr 17, 2019 at 2:52 PM Dan Williams <dan.j.williams@intel.com=
> wrote:
> >>>
> >>> Up-level the local section size and mask from kernel/memremap.c to
> >>> global definitions.  These will be used by the new sub-section hotplu=
g
> >>> support.
> >>>
> >>> Cc: Michal Hocko <mhocko@suse.com>
> >>> Cc: Vlastimil Babka <vbabka@suse.cz>
> >>> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> >>> Cc: Logan Gunthorpe <logang@deltatee.com>
> >>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> >>
> >> Should be dropped from this series as it has been replaced by a very
> >> similar patch in the mainline:
> >>
> >> 7c697d7fb5cb14ef60e2b687333ba3efb74f73da
> >>   mm/memremap: Rename and consolidate SECTION_SIZE
> >
> > I saw that patch fly by and acked it, but I have not seen it picked up
> > anywhere. I grabbed latest -linus and -next, but don't see that
> > commit.
> >
> > $ git show 7c697d7fb5cb14ef60e2b687333ba3efb74f73da
> > fatal: bad object 7c697d7fb5cb14ef60e2b687333ba3efb74f73da
>
> Yeah, I don't recognise that ID either, nor have I had any notifications
> that Andrew's picked up anything of mine yet :/

Sorry for the confusion. I thought I checked in a master branch, but
turns out I checked in a branch where I applied arm hotremove patches
and Robin's patch as well. These two patches are essentially the same,
so which one goes first the other should be dropped.

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

Thank you,
Pasha

>
> Robin.

