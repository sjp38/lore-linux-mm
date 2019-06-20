Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEC4DC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:56:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A12B32070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:56:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="L68JUZMs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A12B32070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 335DC6B0005; Thu, 20 Jun 2019 12:56:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E65C8E0003; Thu, 20 Jun 2019 12:56:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AE608E0001; Thu, 20 Jun 2019 12:56:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E4E4D6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:56:52 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id y81so1565149oig.19
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:56:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fOYLp6hgueM9IndZ4EN5g0OtG+v2NmbcnIaY4S6F39U=;
        b=Uf0kWGMmjQeeYd0x1/OEXY5KZ6FES2jppJNrUdL4kcvOHgoAlqmjR922TUMp+NSeID
         L48xtPeahTwcCRcQX7XWjbhpJf8vH97NyfykP0wtJurbpJ08eTP5kEB+6u5Vk59LGfSM
         mqgCM2hgpDUje3WiFIq5FxjXWgPZXI5GG4/Z1WmuExGS7efhZo0TRdKAq0kfMGHmi26p
         8YmS0KzFWzzQpywbvViS84wc7wUc/slM9Oiqrf/eEQhREyZdVH2MEAkZ+lae/PC5aA+T
         +twFWESvs3kwhGdxLAWqqwa7JBQ2MFNm3YOhtkEH97jp5KMXrW+hVUdshqwpjMqYNoq7
         vuQQ==
X-Gm-Message-State: APjAAAVh4kqfhOkknQy320H8ImfJiE5sNWUi5d/NG/BCnXjARFob5kpK
	qNG0+y7U5cJ7ywgdgZxYXSby1iS7JiEK8PXyo/IcozJjNWh2VrUM7jLhVjE3wiFheNEga7VxD8L
	49ZvkBZtu5WnPlHp74W+3a/adt9ujB8BHu2nza8DmVZ0p04MBr5TRIpQyjxLG8A8cwA==
X-Received: by 2002:a9d:6059:: with SMTP id v25mr5741116otj.90.1561049812607;
        Thu, 20 Jun 2019 09:56:52 -0700 (PDT)
X-Received: by 2002:a9d:6059:: with SMTP id v25mr5741075otj.90.1561049811980;
        Thu, 20 Jun 2019 09:56:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561049811; cv=none;
        d=google.com; s=arc-20160816;
        b=GwBk9PMJMy2pG7HVziumPPpO/FR58PLU+7eWsnd/rG0ysCyXAX9z4L3yg4eIbT/U4L
         ZdsZQ8WNIIYFWFsbbA6ABLyguO9XwrbdgVe5LuRKu6afQGxLcwDEQ5ZqhdedwXe6ZEVe
         2mnGkkvjY81S0fu1M6Pmq8ulbuLvBXMw7RTrFaChU5oM43ZUeQ5tfk8fpB7h39BIagO6
         gvVz9usPXPcQAd7VCDTeSjFre51E8AUEjwFj0Vd2gGfKXnMGL06E+HVEGvhN2L8U85oK
         2lhdpOWl0qGFyaNKnwAsaVEd2ufvTneKhgm6EZgkPJ0P4io1WqUKOf56pi/SaoKYGneX
         rf/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fOYLp6hgueM9IndZ4EN5g0OtG+v2NmbcnIaY4S6F39U=;
        b=qsl7HuXmS521MvADRe2pVlhdTAclzOKUC1KKkXCv5jZIbAnugc56Gu54d7MPhbzDi9
         Cmo/CcDRZb7D/77BYOLxj2Z8UYAuqez9PpGSo6ENmdVmbl66+PCJdGjXhxWxF0otQFov
         8ZcndPE0VyhbJnThfNdrN4GytZUV/gFEGQPJbum3gx0MwKdsN7HYTThouh/UkfhPzov+
         ogMi6/vY/yVk2NqmmbNUd0LT30T4csBowuP1w4yfdDS4JgL3Pshg8pWKdz72l+0mUSDb
         rTjpL5+86hpjPTpCp/Hdg3M4ohCdZRbCL3XE6Ik0f7q7RweCNb2TG89pRbzIjI1gpgQK
         T+rA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=L68JUZMs;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c22sor198144otn.18.2019.06.20.09.56.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 09:56:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=L68JUZMs;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fOYLp6hgueM9IndZ4EN5g0OtG+v2NmbcnIaY4S6F39U=;
        b=L68JUZMsU50kQvIyjv7hYWpW6X5xm6ttiDbx+i1flV2loGovu9oLWT0/Oq0wGyvjeF
         fDEHYCjmDgMEzsqFCqfiwLyn1WQa64ztrAwo98O+v66/orGKTWwb8digBS49x4Pflf0Y
         GwbN3GlvDERuyFfH3JoFUUNtodv7ywBBM2TNpqAPqosJAz3+HCLcKrjjimfxbGpOg1yh
         IhpZaJAeuld4fCSpSEEQG7eW9hIzMlX+fOOfur9Rk2uW98EI4n5HVk+orDvRtVpaeJBG
         tFfo8SvN6kMdSRGx7QadqpWCbafgyp8LgUUrcNOCgoFyaIAfeIsdRck4L783SXqbI9Af
         3HIw==
X-Google-Smtp-Source: APXvYqz6ECdin+kIXbEiVFPFwyQWlqLQpDqZZas2KQgUhlFbQVpZ8YHHJuT5Ae4Hj9wp2NSwJaLXdBacSsagD2vdyWg=
X-Received: by 2002:a9d:7a8b:: with SMTP id l11mr200928otn.247.1561049811653;
 Thu, 20 Jun 2019 09:56:51 -0700 (PDT)
MIME-Version: 1.0
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
 <156092353780.979959.9713046515562743194.stgit@dwillia2-desk3.amr.corp.intel.com>
 <70f3559b-2832-67eb-0715-ed9f856f6ed9@redhat.com> <CAPcyv4jzELzrf-p6ujUwdXN2FRe0WCNhpTziP2-z4-8uBSSp7A@mail.gmail.com>
 <d62e1f2f-70db-da84-5cc3-01fab779aeb7@redhat.com>
In-Reply-To: <d62e1f2f-70db-da84-5cc3-01fab779aeb7@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Jun 2019 09:56:40 -0700
Message-ID: <CAPcyv4j-XxP_8kWbZpv2z94kDjxTB8RBMYGkKr1WopqsfhqdmA@mail.gmail.com>
Subject: Re: [PATCH v10 08/13] mm/sparsemem: Prepare for sub-section ranges
To: David Hildenbrand <david@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 9:37 AM David Hildenbrand <david@redhat.com> wrote:
>
> On 20.06.19 18:19, Dan Williams wrote:
> > On Thu, Jun 20, 2019 at 3:31 AM David Hildenbrand <david@redhat.com> wrote:
> >>
> >> On 19.06.19 07:52, Dan Williams wrote:
> >>> Prepare the memory hot-{add,remove} paths for handling sub-section
> >>> ranges by plumbing the starting page frame and number of pages being
> >>> handled through arch_{add,remove}_memory() to
> >>> sparse_{add,remove}_one_section().
> >>>
> >>> This is simply plumbing, small cleanups, and some identifier renames. No
> >>> intended functional changes.
> >>>
> >>> Cc: Michal Hocko <mhocko@suse.com>
> >>> Cc: Vlastimil Babka <vbabka@suse.cz>
> >>> Cc: Logan Gunthorpe <logang@deltatee.com>
> >>> Cc: Oscar Salvador <osalvador@suse.de>
> >>> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> >>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> >>> ---
> >>>  include/linux/memory_hotplug.h |    5 +-
> >>>  mm/memory_hotplug.c            |  114 +++++++++++++++++++++++++---------------
> >>>  mm/sparse.c                    |   16 ++----
> >>>  3 files changed, 81 insertions(+), 54 deletions(-)
> > [..]
> >>> @@ -528,31 +556,31 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
> >>>   * sure that pages are marked reserved and zones are adjust properly by
> >>>   * calling offline_pages().
> >>>   */
> >>> -void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> >>> +void __remove_pages(struct zone *zone, unsigned long pfn,
> >>>                   unsigned long nr_pages, struct vmem_altmap *altmap)
> >>>  {
> >>> -     unsigned long i;
> >>>       unsigned long map_offset = 0;
> >>> -     int sections_to_remove;
> >>> +     int i, start_sec, end_sec;
> >>
> >> As mentioned in v9, use "unsigned long" for start_sec and end_sec please.
> >
> > Honestly I saw you and Andrew going back and forth about "unsigned
> > long i" that I thought this would be handled by a follow on patchset
> > when that debate settled.
> >
>
> I'll send a fixup then, once this patch set is final - hoping I won't
> forget about it (that's why I asked about using these types in the first
> place).

It's in Andrew's tree now, I'll send an incremental patch.

