Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C92DC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:16:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC1A72081C
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:16:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Wglm0Ja8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC1A72081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 727326B0003; Thu,  2 May 2019 10:16:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D8D16B0006; Thu,  2 May 2019 10:16:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A06B6B0007; Thu,  2 May 2019 10:16:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCDF6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 10:16:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h12so1118711edl.23
        for <linux-mm@kvack.org>; Thu, 02 May 2019 07:16:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=F9aLUsv55ITOjNiKYrvVJTstOAfJJ4bjs1xsqsYJZDQ=;
        b=SwUaI1Y4yH0dE3jSPJjR6V6SMZAOMl7r6DZGS4rTP+gJ91J05j6+NG4EPwMoSf+ORb
         QXgfEeOGvIxIIc6YL2e9yLYsvOBdw4YzQsWMIi+tjpd9xElt22MGRoZqvIlyGfV/+chM
         qMilNzenQkDqT1Ebc5CPs1SbnepY6v3e/7WD5yWVt0t/s7PyfARYLGW3GsIOjv4CatM2
         bOBk9I9vPsJWCcrgzFEtttSKNy24gmbmowJ/EO3FJWfQgKRVINhMI/nClSSzzvQ1rLqX
         1o39sInoG32m0L1KbhcoF0hmbpXdW/mm4BzdOnl4XAuBjXVGw1Q1W9bFOo2o5Gqr6AtV
         dL5A==
X-Gm-Message-State: APjAAAU463py4PYpYayUgebBRiMHszH2ohce/nDHQGFLH4hJ2DF9cBDX
	CgPwKr95uC1KkNmWOQ5SvMPdnooQzOGcZc/c0pebCZMoYfUGETC+cQvrPnVXaCktJjZy0mzlCRA
	KXcalYV/GitRIkFZPXeiRZiU06OF/qx4Who6DA6gkQRg72Pu3a0KSB3rwbiyeUWAaAg==
X-Received: by 2002:a50:9264:: with SMTP id j33mr2643859eda.125.1556806580616;
        Thu, 02 May 2019 07:16:20 -0700 (PDT)
X-Received: by 2002:a50:9264:: with SMTP id j33mr2643812eda.125.1556806579883;
        Thu, 02 May 2019 07:16:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556806579; cv=none;
        d=google.com; s=arc-20160816;
        b=APzBSYjcU9Calxa/vFMDeHk1R60qVAwuMCx9n4oHaS9ff0EeonjLOsqA2zXqQTNhq0
         0YmKrKINFjwveTnhdiJKhCm1djsbpRSnmsqo0bn48pTEEGpn1coUOtRLwGfmD7FtbSSy
         350uQ4hbwBKEW4NTNs+b91WOoBFXuEeEHKCWgyJQBtWZxrgA0MI2JeRJBo1oRKwt0Zff
         zn50pk/Z9VbrUMSit4jIuM3wJJpOrzNhhzI0QbJz7R/VwLv6exEhtN62GnXSj8ryRqwA
         pNSGOIXGxV61CuVO2BtKuxBdJWvPW0fq+ENV79uUQ4hGvAiiK2RG//1MOpeXm0RR/8u4
         XNoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=F9aLUsv55ITOjNiKYrvVJTstOAfJJ4bjs1xsqsYJZDQ=;
        b=J12y0q0Zs7JVZQamyUM/4TOGe8PEBSjCcdjmNfJNfkxvWkAxkJcpjxKajg+KGseMiJ
         bP9I3hBkrr/PyeMBp/hPyg74MTevxPqJsIb56NwgSl1huikBkM3FH4J5612kq1ubzX9J
         i4E6671ySnUdv1fYuerGViqM2ErTSuJGJH0vk/k+H0oXqG8xg3Ab0JPYFA1nlG0zqIri
         aAsWSd5VSlkPvJJ0+jv8CGSiOkv/IIytZh0IfBP2uKfHRLeYlAiEAYhnLzeq1keTAPRf
         3YmFov3c12A+tnE0V7lQF9ZuBka85bPektYwwfZCRAJLkgZL2ckXQ+BgjA7Adz85uweK
         0YKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Wglm0Ja8;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v22sor4473920edc.13.2019.05.02.07.16.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 07:16:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Wglm0Ja8;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=F9aLUsv55ITOjNiKYrvVJTstOAfJJ4bjs1xsqsYJZDQ=;
        b=Wglm0Ja8Is5t6Pe+C39FK43FXDgUihPAL66hPy1y4u5yc2bjsKAODKww+7X5qtMNq5
         PbUXwFDcvRFq0LAgV2XIV24RKvFaLy4+Jk9GJYezxhn5AlNEzzhz8abjwcZNxXD9zlji
         e5nlWFVG4bsIB4/YdkBoDHM6o1TSAyn93KJf3vcwSYLmgFnlgEumav98ILuqSoa4je8o
         AFbnIN4HyiGrHybIdEqKo89zqDoKruqFcQ4OfcjnNLSk5jVrpkfQPrVUs7D0XYOyds57
         zhuWswdfRLeN+sHLVlfRkfc2fNW9damh+qz/C5Exemg6en0dyyKw1qNwtwq2GtQLO5wR
         RaFg==
X-Google-Smtp-Source: APXvYqz9Dz0MllP0/JVZaWYqSMxagrbWwyxnqyReg5hTSdZBuyzEtjj571LYBRrDHp5eRfJaAMIOIYRbPk8/bxfuLaY=
X-Received: by 2002:a50:a951:: with SMTP id m17mr2606324edc.79.1556806579550;
 Thu, 02 May 2019 07:16:19 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552634075.2015392.3371070426600230054.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190501232517.crbmgcuk7u4gvujr@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAPcyv4hxy86gWN3ncTQmHi8DT31k8YzsweMfGHgCh=sORMQQcg@mail.gmail.com>
In-Reply-To: <CAPcyv4hxy86gWN3ncTQmHi8DT31k8YzsweMfGHgCh=sORMQQcg@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 10:16:08 -0400
Message-ID: <CA+CK2bA_5uaEK1vjOwNZC9Ta+T-_yTL9etOUEvOUSrtNEOe8og@mail.gmail.com>
Subject: Re: [PATCH v6 01/12] mm/sparsemem: Introduce struct mem_section_usage
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 2, 2019 at 2:07 AM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Wed, May 1, 2019 at 4:25 PM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
> >
> > On 19-04-17 11:39:00, Dan Williams wrote:
> > > Towards enabling memory hotplug to track partial population of a
> > > section, introduce 'struct mem_section_usage'.
> > >
> > > A pointer to a 'struct mem_section_usage' instance replaces the existing
> > > pointer to a 'pageblock_flags' bitmap. Effectively it adds one more
> > > 'unsigned long' beyond the 'pageblock_flags' (usemap) allocation to
> > > house a new 'map_active' bitmap.  The new bitmap enables the memory
> > > hot{plug,remove} implementation to act on incremental sub-divisions of a
> > > section.
> > >
> > > The primary motivation for this functionality is to support platforms
> > > that mix "System RAM" and "Persistent Memory" within a single section,
> > > or multiple PMEM ranges with different mapping lifetimes within a single
> > > section. The section restriction for hotplug has caused an ongoing saga
> > > of hacks and bugs for devm_memremap_pages() users.
> > >
> > > Beyond the fixups to teach existing paths how to retrieve the 'usemap'
> > > from a section, and updates to usemap allocation path, there are no
> > > expected behavior changes.
> > >
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Vlastimil Babka <vbabka@suse.cz>
> > > Cc: Logan Gunthorpe <logang@deltatee.com>
> > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

