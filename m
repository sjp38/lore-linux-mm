Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5828C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:05:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FF0F20693
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:05:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FF0F20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43A4F6B0005; Tue, 23 Apr 2019 12:05:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E9726B0007; Tue, 23 Apr 2019 12:05:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D9EF6B0008; Tue, 23 Apr 2019 12:05:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D05BB6B0005
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:05:33 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id q17so8225980eda.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:05:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uAHY0wf1u2BiqDnvhotMH2pZWcfDhYETaV9BWTFbLFo=;
        b=P3UEt0T9gliRNbKV6ILN0x+wKNqy92C/amYwDf1l8q6jawjZv8CljVgxVhp8gNSuyN
         wjMI/WshWyPg6pzuPOmG0FNv5ovCLYh3/5XZhBlBbUEhZOLHoZM5YBAwE4dC0A8V+Hp3
         PNdxGB3bkLvfxjy60UZEfIBTW8WpKyZamSPxxo/kwEV1R/JP40/OLsEBg2B/BwLP5vFI
         Z2VDvEk5JOdNl9xTHDRbM+Ty8vaPq0FFO4WuBa/OMycH8WQh10+RXlQ5a9TRezjC7HUd
         hsBGQCOgyb/HoPwwPZvY8YEi4qYK1RqfDY3QxUTwhuEKzzE/byCerQ1cyvbGrcaxqhpx
         XlZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAXcg7zD7P7mCASsBQkoceScNYZ7pGXd0Df3VGhxWenXQXci+llv
	H9kQKt+jdFiTc4Hj+KlO/hp3kRP5TO/B3prFCTsaYHsfmlwnKXqw4FF9xFB6qE8FKvCw7Y38bY2
	ZxNXoDnmBszKjZhJDoVesDyuM2qtP/aQRucmzqMwoRMwOA6s7WDC9xZXA0piZSNQCBQ==
X-Received: by 2002:a50:8bbd:: with SMTP id m58mr16801617edm.42.1556035533423;
        Tue, 23 Apr 2019 09:05:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFZSjwwVxeAr7JXt6ko4SSXINCyFitvS6aEebKhpihNA1GhlLvQD78FfUDVxSN4Fyr1hq9
X-Received: by 2002:a50:8bbd:: with SMTP id m58mr16801540edm.42.1556035532558;
        Tue, 23 Apr 2019 09:05:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556035532; cv=none;
        d=google.com; s=arc-20160816;
        b=1B0Buyw7w7etkkzP8ylZ7OshmtEvn9Yg6bMC1xTLmrYub7DYv3cXzsC70aVmMBNXP0
         tUfmsu6RIA4hzj0IvDiYLmiMftG4qTkvaTetaZvPDNv50szWCyR6PEA1iVF8QmW8PVGf
         83/TA+/f8uPu3RThK2/DxltfGi87dP+JUYGryouREulLhZQqeZ69RXaVzR6oGNogz1/m
         1wWqMZx14dJzBQ8NBDl/Wi1fOwQ6aBHygYCe9EL1PM1GY793ViPUjCYtoKbPHwat6Cxn
         YktiFSBR8jGID/6tkIiyHY9MCL+YC/OZWEC56P0ZV4vyJNP8SciWs8A1AGfkKrc8gWtk
         h7kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uAHY0wf1u2BiqDnvhotMH2pZWcfDhYETaV9BWTFbLFo=;
        b=Eh92lY+H2T3e2sh5k+ZUZrBW/WGIMf2j8nCNRJOhD6n7rEfLN9urDX9xh7guQ+tRFU
         rM72SzSBa/ZfCh+xg/B40atljM0KeO8G5d9HAy39TM+5ortkBbU2E98aJvDc3UdJmSzU
         PBPxhy7DSsn53fLS/vODvTTbo9JmG7f2IC1mqqSLOwmgaOTaQLLAp74RvkAx6G1rQK52
         tKnLSw+IY1qdYmCLmD8mdjM1aiPZhkgNt1FzLaTWS1NnN5gfWH/M0bWZ8xRQdSuq+SQt
         6+gT0Lr3FSPZDZirM7ECp01X2ssb+e4u8uCru42i5f2IvR2iG2bVGrHbUO0cV00lREup
         Hp3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b23si3411840ejq.15.2019.04.23.09.05.32
        for <linux-mm@kvack.org>;
        Tue, 23 Apr 2019 09:05:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3BA8280D;
	Tue, 23 Apr 2019 09:05:31 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 039593F5AF;
	Tue, 23 Apr 2019 09:05:27 -0700 (PDT)
Date: Tue, 23 Apr 2019 17:05:25 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, mhocko@suse.com,
	mgorman@techsingularity.net, james.morse@arm.com,
	robin.murphy@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, osalvador@suse.de, david@redhat.com,
	cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
Message-ID: <20190423160525.GD56999@lakrids.cambridge.arm.com>
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
 <20190415134841.GC13990@lakrids.cambridge.arm.com>
 <2faba38b-ab79-2dda-1b3c-ada5054d91fa@arm.com>
 <20190417142154.GA393@lakrids.cambridge.arm.com>
 <bba0b71c-2d04-d589-e2bf-5de37806548f@arm.com>
 <20190417173948.GB15589@lakrids.cambridge.arm.com>
 <1bdae67b-fcd6-7868-8a92-c8a306c04ec6@arm.com>
 <97413c39-a4a9-ea1b-7093-eb18f950aad7@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <97413c39-a4a9-ea1b-7093-eb18f950aad7@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 01:01:58PM +0530, Anshuman Khandual wrote:
> Generic usage for init_mm.pagetable_lock
> 
> Unless I have missed something else these are the generic init_mm kernel page table
> modifiers at runtime (at least which uses init_mm.page_table_lock)
> 
> 	1. ioremap_page_range()		/* Mapped I/O memory area */
> 	2. apply_to_page_range()	/* Change existing kernel linear map */
> 	3. vmap_page_range()		/* Vmalloc area */

Internally, those all use the __p??_alloc() functions to handle racy
additions by transiently taking the PTL when installing a new table, but
otherwise walk kernel tables _without_ the PTL held. Note that none of
these ever free an intermediate level of table.

I believe that the idea is that operations on separate VMAs should never
conflict at the leaf level, and operations on the same VMA should be
serialised somehow w.r.t. that VMA.

AFAICT, these functions are _never_ called on the linear/direct map or
vmemmap VA ranges, and whether or not these can conflict with hot-remove
is entirely dependent on whether those ranges can share a level of table
with the vmalloc region.

Do you know how likely that is to occur? e.g. what proportion of the
vmalloc region may share a level of table with the linear or vmemmap
regions in a typical arm64 or x86 configuration? Can we deliberately
provoke this failure case?

[...]

> In all of the above.
> 
> - Page table pages [p4d|pud|pmd|pte]_alloc_[kernel] settings are
>   protected with init_mm.page_table_lock

Racy addition is protect in this manner.

> - Should not it require init_mm.page_table_lock for all leaf level
>   (PUD|PMD|PTE) modification as well ?

As above, I believe that the PTL is assumed to not be necessary there
since other mutual exclusion should be in effect to prevent racy
modification of leaf entries.

> - Should not this require init_mm.page_table_lock for page table walk
>   itself ?
> 
> Not taking an overall lock for all these three operations will
> potentially race with an ongoing memory hot remove operation which
> takes an overall lock as proposed. Wondering if this has this been
> safe till now ?

I suspect that the answer is that hot-remove is not thoroughly
stress-tested today, and conflicts are possible but rare.

As above, can we figure out how likely conflicts are, and try to come up
with a stress test?

Is it possible to avoid these specific conflicts (ignoring ptdump) by
aligning VA regions such that they cannot share intermediate levels of
table?

Thanks,
Mark.

