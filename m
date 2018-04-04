Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C42666B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 01:11:18 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t1-v6so12865633plb.5
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 22:11:18 -0700 (PDT)
Received: from lgeamrelo12.lge.com (lgeamrelo12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id u91-v6si2295499plb.698.2018.04.03.22.11.16
        for <linux-mm@kvack.org>;
        Tue, 03 Apr 2018 22:11:17 -0700 (PDT)
Date: Wed, 4 Apr 2018 14:11:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [LSF/MM TOPIC] CMA and larger page sizes
Message-ID: <20180404051115.GC6628@js1304-desktop>
References: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
 <20180126172527.GI5027@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180126172527.GI5027@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Laura Abbott <labbott@redhat.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

Hello, Laura.
Sorry for a late response.


On Fri, Jan 26, 2018 at 06:25:27PM +0100, Michal Hocko wrote:
> [Ccing Joonsoo]

Thanks! Michal.

> 
> On Fri 26-01-18 02:08:14, Laura Abbott wrote:
> > CMA as it's currently designed requires alignment to the pageblock size c.f.
> > 
> >         /*
> >          * Sanitise input arguments.
> >          * Pages both ends in CMA area could be merged into adjacent unmovable
> >          * migratetype page by page allocator's buddy algorithm. In the case,
> >          * you couldn't get a contiguous memory, which is not what we want.
> >          */
> >         alignment = max(alignment,  (phys_addr_t)PAGE_SIZE <<
> >                           max_t(unsigned long, MAX_ORDER - 1, pageblock_order));
> > 
> > 
> > On arm64 with 64K page size and transparent huge page, this gives an alignment
> > of 512MB. This is quite restrictive and can eat up significant portions of
> > memory on smaller memory targets. Adjusting the configuration options really
> > isn't ideal for distributions that aim to have a single image which runs on
> > all targets.
> > 
> > Approaches I've thought about:
> > - Making CMA alignment less restrictive (and dealing with the fallout from
> > the comment above)
> > - Command line option to force a reasonable alignment

If the patchset 'manage the memory of the CMA area by using the ZONE_MOVABLE' is
merged, this restriction can be removed since there is no unmovable
pageblock in ZONE_MOVABLE. Just quick thought. :)

Thanks.
