Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 035B5C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:43:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96AA32175B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:43:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="dvJtRlOF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96AA32175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28CE96B0005; Wed, 24 Apr 2019 16:43:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23BA36B0006; Wed, 24 Apr 2019 16:43:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 152556B0007; Wed, 24 Apr 2019 16:43:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B7E8C6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 16:43:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m47so10569643edd.15
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:43:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3uQ6pt/79DaqV1w1HqJ3riyr5/sBvHSK6/Hzd6NMzp4=;
        b=W3VHHdenQq1x8/4bWfD31nisAGkUqGdri7+iJ8zL5dgcX8u+l9GFfpdmvJGUik2MHS
         oZKS4fwKsMUfrSlj7iBk6e/4mZEWvJR0/pUJUss6EU+m8oXVKNRyqtQB+ywX35k7kKmn
         oG5cM27dmuU+RsGaSWvWKA0BlA3gAjsoefc3EDLrC+gyIsB7cIdv/5/8fj1iLo7HQo+7
         l1rGXPG04GFp1jNWTodnL+Qg+hR9qFtjs76Jey9+Ul0AJft1RetcDMjy72f/IZOMfoEA
         R86OrD8PFAFEE1h8EP2OXa00RWuK10t0NYkt6cAwQzOzn/GVVWN82rHZyC6TznlvnD58
         C2Iw==
X-Gm-Message-State: APjAAAVStFVkhzl3MYr3Hx9w2zvxfmoH963GRWqD1tV4VimN69Fiv2wn
	73fPCJDPAFKdvlhokD7T4aU895R5AbJMa4kHuStFxfYnHv/vVs6hhHyhtDsRe2ez5ZgZ/TgrBhh
	CQxUvPrwV8fZdxDVSEMYR0iMSQR2TmIME9ioneSocuie/c84fvL03BPTmBQgAfk0+FQ==
X-Received: by 2002:a50:9707:: with SMTP id c7mr21651116edb.222.1556138627298;
        Wed, 24 Apr 2019 13:43:47 -0700 (PDT)
X-Received: by 2002:a50:9707:: with SMTP id c7mr21651086edb.222.1556138626582;
        Wed, 24 Apr 2019 13:43:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556138626; cv=none;
        d=google.com; s=arc-20160816;
        b=w3wMGDiZlZ+KCjsnNvpQe7UTmWvvJkISSyBftxGXf2ZdstOlQJMInhkl3ZmPjGorYS
         SjGTUsKsSXkcbSpZ5RaZnnW8b8Jp310tOuE8/d1rqUqb9T55lTu1JaPm+PuqcqyLUAte
         CxOXwPvDJWFTT8/Moxzo7xh4qtmsqHoFOsWTzYp0d8fUnedrMipXTfMhDbmvL0RsC7ql
         ekSW4p4qTvaQo1C8J5w4z+qNR/XS1kL8KIuBIcJrZUL/ZNNwaE6ZFU1cbCS0YtZBT4OU
         Tv2SaGSfy2f/4L2HUZM6JZQepNQCMa9jR5a5iIzoy6bPDCwF+m1CDN3IuChrsXzaMPiy
         4qaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3uQ6pt/79DaqV1w1HqJ3riyr5/sBvHSK6/Hzd6NMzp4=;
        b=AbUbmTnWkcszvVq6xbvHmlsZ7gHRAr82Qd43HSyQloEaT2W6ew2sZhn8of8ooCaaZD
         TaZlYlRhynmeX7FJIN2FfaW8vHWh/m5nJEqI7oUoXSjxwUe/T0YRZLI+pEn4ZdVjnbaO
         10NcusimWNa0GEDnpsILu3WkyuqswsvGRVVm/pngpyIRCSiFNFvK8AifmUwsNNi0fyWY
         I01qJ0SHVn/QmODWXJXAIM7ZwmlKR1xlVeazyVktYfoO/TyvOH+7ddHB0CuvD3oaLn2j
         v+XOJqmvBrM3DcO175iCC5ebOKJFOSlQ6/CRI3vGPvg/l4zUs7yhilJxc6mpYKe4y+QW
         DZaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=dvJtRlOF;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p26sor11028040edy.1.2019.04.24.13.43.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 13:43:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=dvJtRlOF;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3uQ6pt/79DaqV1w1HqJ3riyr5/sBvHSK6/Hzd6NMzp4=;
        b=dvJtRlOFxT2cfx81ZV1rLhKqHcn8wP2dkltllzCy9vGNw9dCzrxYafuNn9nXLujGYh
         r8KoU13+AeniwVXgc+5SvHyy9qPkc7xV8mX4t5Ed52uWdqlkciy8+zrrvBToREKKetCx
         pxTzVNN/CnXf7j+4dQlzA5QY3JiiQz92Hpz12WJH2+ZRoxvVV8GsZKUg9UmhLUN3M+lw
         JYhxE8Qqw62YesIQjDOqszN5E4+qjxPaCr3WTjbqXxAYnnL65L2o2yzdlmsYe1NcqCtJ
         r1EHPXmGQtacfX2M02uzrnZwa6pNZgYpC0gjFWqjsm9oCIFQqctsxRZaZfWoXNg54JXI
         LHcg==
X-Google-Smtp-Source: APXvYqwwtgxviomoeB178elsaWelBPDBbhr4KEN1wrW4lNWd86vBErwAgnmmMXG7JMKrSJmUjpuHPaC2EjvlBKqmsPs=
X-Received: by 2002:a50:978e:: with SMTP id e14mr21377731edb.91.1556138626271;
 Wed, 24 Apr 2019 13:43:46 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190417150331.90219ca42a1c0db8632d0fd5@linux-foundation.org>
 <CAPcyv4hB47NJrVi1sm+7msL+6dJNhBD10BJbtLPZRcK2JK6+pg@mail.gmail.com> <1556025416.2956.0.camel@suse.de>
In-Reply-To: <1556025416.2956.0.camel@suse.de>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Wed, 24 Apr 2019 16:43:35 -0400
Message-ID: <CA+CK2bBS_cWJCWDCQAXKU6t=r=nAC908jz8uQ90DjKT5XcuNtw@mail.gmail.com>
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
To: Oscar Salvador <osalvador@suse.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	David Hildenbrand <david@redhat.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I am also taking a look at this work now. I will review and test it in
the next couple of days.

Pasha

On Tue, Apr 23, 2019 at 9:17 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> On Wed, 2019-04-17 at 15:59 -0700, Dan Williams wrote:
> > On Wed, Apr 17, 2019 at 3:04 PM Andrew Morton <akpm@linux-foundation.
> > org> wrote:
> > >
> > > On Wed, 17 Apr 2019 11:38:55 -0700 Dan Williams <dan.j.williams@int
> > > el.com> wrote:
> > >
> > > > The memory hotplug section is an arbitrary / convenient unit for
> > > > memory
> > > > hotplug. 'Section-size' units have bled into the user interface
> > > > ('memblock' sysfs) and can not be changed without breaking
> > > > existing
> > > > userspace. The section-size constraint, while mostly benign for
> > > > typical
> > > > memory hotplug, has and continues to wreak havoc with 'device-
> > > > memory'
> > > > use cases, persistent memory (pmem) in particular. Recall that
> > > > pmem uses
> > > > devm_memremap_pages(), and subsequently arch_add_memory(), to
> > > > allocate a
> > > > 'struct page' memmap for pmem. However, it does not use the
> > > > 'bottom
> > > > half' of memory hotplug, i.e. never marks pmem pages online and
> > > > never
> > > > exposes the userspace memblock interface for pmem. This leaves an
> > > > opening to redress the section-size constraint.
> > >
> > > v6 and we're not showing any review activity.  Who would be
> > > suitable
> > > people to help out here?
> >
> > There was quite a bit of review of the cover letter from Michal and
> > David, but you're right the details not so much as of yet. I'd like
> > to
> > call out other people where I can reciprocate with some review of my
> > own. Oscar's altmap work looks like a good candidate for that.
>
> Thanks Dan for ccing me.
> I will take a look at the patches soon.
>
> --
> Oscar Salvador
> SUSE L3

