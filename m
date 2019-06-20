Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43F68C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:30:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 089212084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:30:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="IbYvmcN3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 089212084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71A748E0006; Thu, 20 Jun 2019 12:30:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F1A48E0001; Thu, 20 Jun 2019 12:30:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 607ED8E0006; Thu, 20 Jun 2019 12:30:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 389F98E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:30:23 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id b25so1484450otp.12
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:30:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DApYrgtFGUX8hglw1AcOz6adgUtgKXSMo50u9kqGqWo=;
        b=ejwbL3OnpF6h5gi4VBceCLSweow1Ej/Aw9B0/gNl4odDbwv4cQbklH/hWZpTzrSHjr
         fRvObLVcUYbTGAPfxpTQpBumgu4meO6sH4zMye1LHCo4uo4eEQeu0FhAQUSWLcRnlGBK
         Rqje3d1jRVisC3O429mXmdgJZlN4Nkg9QXC+fEyLSEAcoa9XPuQ5AqoBp+TArW7rLFih
         riZ8IjsEetjtZ2W1Wqw3TRKCQHVm9iybqr+QNOjDQJphKng4T+hNlkhoq+VPnFxhXC/O
         /+qEAJH4jguLLOHPHazDa/yVLP9n+LhQFAqwQBJsiHPhglOyBHDPxVQSjEQiuEW31W1H
         EXlQ==
X-Gm-Message-State: APjAAAVWg9Gk7/L88uu3AOQa+tvjrKFQk459P8cJ9jeEVBjnz9S9YHyK
	cfhorK57ZDLV1zwH8ENe9Tr6ZjRScICLmnIdS1zAe9s0Us4IfZDrPDztsJttEcfPiAJB08wlPc8
	PSOyOzxyzeIf7pMnItpQd4BJDGMID/t96MG2yTOyU7HYV5ZzC3OZjzoFiXAgsf7iRww==
X-Received: by 2002:a9d:7248:: with SMTP id a8mr1791654otk.363.1561048222849;
        Thu, 20 Jun 2019 09:30:22 -0700 (PDT)
X-Received: by 2002:a9d:7248:: with SMTP id a8mr1791588otk.363.1561048221771;
        Thu, 20 Jun 2019 09:30:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561048221; cv=none;
        d=google.com; s=arc-20160816;
        b=ADhkDP37r6hmjeR0TAI5/3Ux02zkntnZHPYV+2l8cKdGF+0jvJNyQyJ3iFswd+9BwO
         2Ak50766cdRQhYmg6G5/FvB/3ve3Zj1A6XpPFWuWm96ANsYF96b3dbz/UPj0xYAceZMa
         qDs6vECcBAZj7vncdHw7+3/vnEzBe3/gHpPL1M4pL57HQmnoYYnM+cNhEThVkENZ7Obk
         hCsG/klKLakhh9ocFI5nFxWoLDd3++stgmothEB92EJSDJNpk5uWfnnXSswblRyYN6/f
         1okFI8S7QzOZJxS+m7ziTlxNkiO1Ad1jmrGikno2636fswYxf5z6c9aucbVgztQBc62t
         gP3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DApYrgtFGUX8hglw1AcOz6adgUtgKXSMo50u9kqGqWo=;
        b=EeZtvuq7bhKbBktOpCXfkdJk0H5k6pdq1VbmSH+D1hxI1UUBPv3t7mKK967itTTmOx
         GlZHr8DNfJwLS2orrfcYpPpk+Pj8fuYOrcer6uomC48JVIJHUmQxKETQ1hvXnI4+kWA5
         kr79nWK0Oo5mHfaGcrUFczuQOsNBChgY7ymjo030vghDgsaABqSKPk+fSPahXnQY022k
         anqEQbdGQ0HW4C9V5BM7cx4DQvUDBk5GNSQQPMGn6FdEQNMFT/1wkY8PnKb/VA5qE+3g
         TIQpxwSLfCOWU9QG9FnFr0wqeBh+mu2vRbBFXGqd3wV7znALJrfpsgpDJDk76tsp/n0+
         evWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=IbYvmcN3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor139007otk.47.2019.06.20.09.30.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 09:30:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=IbYvmcN3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DApYrgtFGUX8hglw1AcOz6adgUtgKXSMo50u9kqGqWo=;
        b=IbYvmcN3FD1XsFJRWLBVeAh4cj+ztsE2rAJY2j9X45js8FuU/UPlkV5Z4mXnvi7Y7S
         A1GJpNUvJJbYn4ayjrn7/ANF+NiX7qKfqVlzDYpeflENEtIxLPu+qyys3bQLnsGfTQ1q
         nP6mTojxuOtLIWObuYkjJyA/1wtWC7fvvWuTmmiY8UwiqIT0/aeMmX6iPRbPwOg5iGPr
         uvfM5n2Dc7iiy1RvSAtGN0+PsX0kiVynUGI3ramtVIYzCGNtSNnR70SGPuHH87OdZOvD
         shvfqPmJ4PpbxFg34W9zwV3aCJNPq3GMuGB4dV59hH1kuK1Ja8KmFwrH/fL/dTGr3744
         /wLg==
X-Google-Smtp-Source: APXvYqxIllarlavyR5g1oQ37eeWGGe9Qov4pSV/b7aFTtPwH8mY5U/JzeG/yRiJUeWSkE5MXZLJELq2eNsiljKeKmTU=
X-Received: by 2002:a9d:7b48:: with SMTP id f8mr14032030oto.207.1561048221363;
 Thu, 20 Jun 2019 09:30:21 -0700 (PDT)
MIME-Version: 1.0
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
 <874l4kjv6o.fsf@linux.ibm.com>
In-Reply-To: <874l4kjv6o.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 20 Jun 2019 09:30:10 -0700
Message-ID: <CAPcyv4ioWRhU9AbyTHhf9PavL0GSs=6h3dGyaQPb7vLJ2+z23g@mail.gmail.com>
Subject: Re: [PATCH v10 00/13] mm: Sub-section memory hotplug support
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <david@redhat.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Jane Chu <jane.chu@oracle.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Jonathan Corbet <corbet@lwn.net>, Qian Cai <cai@lca.pw>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, 
	Oscar Salvador <osalvador@suse.de>, Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, 
	Wei Yang <richardw.yang@linux.intel.com>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 5:31 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Dan Williams <dan.j.williams@intel.com> writes:
>
> > Changes since v9 [1]:
> > - Fix multiple issues related to the fact that pfn_valid() has
> >   traditionally returned true for any pfn in an 'early' (onlined at
> >   boot) section regardless of whether that pfn represented 'System RAM'.
> >   Teach pfn_valid() to maintain its traditional behavior in the presence
> >   of subsections. Specifically, subsection precision for pfn_valid() is
> >   only considered for non-early / hot-plugged sections. (Qian)
> >
> > - Related to the first item introduce a SECTION_IS_EARLY
> >   (->section_mem_map flag) to remove the existing hacks for determining
> >   an early section by looking at whether the usemap was allocated from the
> >   slab.
> >
> > - Kill off the EEXIST hackery in __add_pages(). It breaks
> >   (arch_add_memory() false-positive) the detection of subsection
> >   collisions reported by section_activate(). It is also obviated by
> >   David's recent reworks to move the 'System RAM' request_region() earlier
> >   in the add_memory() sequence().
> >
> > - Switch to an arch-independent / static subsection-size of 2MB.
> >   Otherwise, a per-arch subsection-size is a roadblock on the path to
> >   persistent memory namespace compatibility across archs. (Jeff)
> >
> > - Update the changelog for "libnvdimm/pfn: Fix fsdax-mode namespace
> >   info-block zero-fields" to clarify that the "Cc: stable" is only there
> >   as safety measure for a distro that decides to backport "libnvdimm/pfn:
> >   Stop padding pmem namespaces to section alignment", otherwise there is
> >   no known bug exposure in older kernels. (Andrew)
> >
> > - Drop some redundant subsection checks (Oscar)
> >
> > - Collect some reviewed-bys
> >
> > [1]: https://lore.kernel.org/lkml/155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com/
>
>
> You can add Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> for ppc64.

Thank you!

> BTW even after this series we have the kernel crash mentioned in the
> below email on reconfigure.
>
> https://lore.kernel.org/linux-mm/20190514025354.9108-1-aneesh.kumar@linux.ibm.com
>
> I guess we need to conclude how the reserve space struct page should be
> initialized ?

Yes, that issue is independent of the subsection changes. I'll take a
closer look.

