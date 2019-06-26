Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46131C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:48:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2A362082F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:48:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2A362082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B4736B0003; Wed, 26 Jun 2019 05:48:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 564D18E0003; Wed, 26 Jun 2019 05:48:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47B598E0002; Wed, 26 Jun 2019 05:48:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F1BD96B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:48:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m23so2383828edr.7
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:48:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rRFQagklTK9A6Qe1ruVIcUORgtYS4vg8lbJALJfIp0Q=;
        b=DelsnJs/wRzt6Obxb03pFrkOCCi6t1smteQzwjL9pIxKquIw6g98jhLPbKtmvc2Txt
         KwrDuWs3hMGHDgfUt6LO2r/1uI83ku0Cs30Ijsk/hIMalFgT4bljZpdjRuLUdh0B1NGI
         PGRNRNiGzbuRXSjXEym2DxcGhtsqQM/9e5Zn1OFa0DVvPva7mJnlNpqbb5br1pb0YS9K
         tonG0AmnnrmoVDHOv1pRjvjZK7KFzf/wadNkSDQG85AaIa3KWDnhJlLvbuX4czOmHVYA
         xM1miFlymf2k42kMu2wHB/q6HMOs5+0j5/op+i+9Lst/P3I2hiMgic/FJGtXfwsrWdue
         FeOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXZ4N1MrhUefN43zxjRcVjSBIaFhPgWni7uMVk2H8x/8OUmmzYV
	Ki70u/sa2LD7/NAqdrZMjLCmIrk5mx+Dzlu2qb7msquGHCp2GICdivedBESGzXPExDLs0PkWORN
	1CTmUKgBfx5ox0qtp3W4YYKZsRyhrcS4Ty3wqTChlCXkadf3xDS8B2PbUatLMMH+RhA==
X-Received: by 2002:a50:b104:: with SMTP id k4mr3959658edd.75.1561542514551;
        Wed, 26 Jun 2019 02:48:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaSQnMP96uWjp/+1iPE7LNvu2kkz0OyUxhpg93oFA0BfAi5i1OLtPpFby4yjfgAUvS3eMn
X-Received: by 2002:a50:b104:: with SMTP id k4mr3959580edd.75.1561542513752;
        Wed, 26 Jun 2019 02:48:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561542513; cv=none;
        d=google.com; s=arc-20160816;
        b=e634W4WSxgeqJTd17834L8ELzz6hLM2okJRfCqNNYhpV8kPTMHuKPGc+Yb2+8aN35j
         3EeOgKPqUOwkmLMR/vsPKceAbXxHFlwvuoBwV3yT0VBI6LjAMWUTKjX52pk9dUylWofP
         Qy56jBzf78CP93NOgjM7v27ht5MhLx6qNU/3LT90hvYyAbkv0PrPA0BN9y5gR14y4LbI
         FLCT0QNuup1nJaksGSga7dxshjh/l9/qB6S/61hNIgjxsmBbCHLZLZP+wz+5jZ/dGc+M
         Wll9ahAzAvtEXMDC5ZeyCHhJkV6ciYKqwCwOgT4wejzjDWAoDFQiDDCfe/DollPAI2uG
         pQ4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rRFQagklTK9A6Qe1ruVIcUORgtYS4vg8lbJALJfIp0Q=;
        b=XiJJS70md32wG2ASiE1TEWzHkJ7vqxTI4rzk7Pz6gtZewfy1fc1Pf8jOjWFKysET5E
         HDKUFq2UfEaei8rOzr//8chLo7oAzMSS/juzT39jtTuT0CNnRROSzjibtBpInUSLVJXk
         nVNFLJ6af+Qbf5TztkyZg5vBT1Pr/bmA4ZCnWenkQB5NllMafBa05peHBADd6okkQFFm
         Hd8CYQmmhShESqaJU2BZCnUP//o8czEfDVKkqfUvpLS55bLMOWBWH/weO52Dn8BHNyka
         EUNJESQT78hU1mKoTUfElwggRiDDkxgYKWoKJbau39qrwV0GegwSjF870yE5a5K/NZUd
         Xsxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q51si3056645eda.207.2019.06.26.02.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 02:48:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BAF37AF0C;
	Wed, 26 Jun 2019 09:48:32 +0000 (UTC)
Date: Wed, 26 Jun 2019 11:48:29 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, vbabka@suse.cz,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 3/5] mm,memory_hotplug: Introduce Vmemmap page helpers
Message-ID: <20190626094823.GA457@linux>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-4-osalvador@suse.de>
 <649ae422-9be8-8d2f-4e8e-f08c1ca9244f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <649ae422-9be8-8d2f-4e8e-f08c1ca9244f@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 12:28:56PM +0200, David Hildenbrand wrote:
> > +static __always_inline void __ClearPageVmemmap(struct page *page)
> > +{
> 
> Should we VM_BUG_ON in case !PG_reserved || pg->mapping != VMEMMAP_PAGE ?

We can do that, just for extra protection.

> 
> > +	__ClearPageReserved(page);
> > +	page->mapping = NULL;
> > +}
> > +
> > +static __always_inline void __SetPageVmemmap(struct page *page)
> > +{
> 
> Should we VM_BUG_ON in case PG_reserved || pg->mapping != NULL ?

ditto.

> 
> > +	__SetPageReserved(page);
> > +	page->mapping = (void *)VMEMMAP_PAGE;
> > +}
> > +
> > +static __always_inline struct page *vmemmap_get_head(struct page *page)
> > +{
> > +	return (struct page *)page->freelist;
> 
> freelist is a "slab, slob and slub" concept (reading
> include/linux/mm_types.h). page->mapping is a "Page cache and anonymous
> pages" concept. Hmmm...

Yeah.
In an early stage, I thought about constructing vmemmap pages the same way
we construct compound pages, so we can leverage the APIs that we already have.

For some reason I did not go further with that, but I will investigate in that
direction.

> I wonder if using a page type would be appropriate here instead. Then,
> define a new sub-structure within "struct page" that describes what you
> actually want (instead of reusing ->private and ->mapping). Just an
> idea, we have to find out if that is possible.
> 
> vmemmap_get_head() smells like __GFP_COMP, but of course, these vmemmap
> pages never saw the buddy. But sounds like you want a similar concept.

Thanks for the feedback.
I will take a look at it.

-- 
Oscar Salvador
SUSE L3

