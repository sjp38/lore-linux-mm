Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A6BE56B0008
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:17:28 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id z2-v6so664581plk.3
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:17:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 32-v6si772510pla.348.2018.04.18.01.17.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 01:17:27 -0700 (PDT)
Date: Wed, 18 Apr 2018 10:17:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] CMA and larger page sizes
Message-ID: <20180418081724.GS17484@dhcp22.suse.cz>
References: <3a3d724e-4d74-9bd8-60f3-f6896cffac7a@redhat.com>
 <20180417113656.GA16083@dhcp22.suse.cz>
 <bc8e54d2-7224-0e8c-d7db-54fc4625eae8@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bc8e54d2-7224-0e8c-d7db-54fc4625eae8@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue 17-04-18 08:01:53, Laura Abbott wrote:
> On 04/17/2018 04:36 AM, Michal Hocko wrote:
> > On Fri 26-01-18 02:08:14, Laura Abbott wrote:
> > > CMA as it's currently designed requires alignment to the pageblock size c.f.
> > > 
> > >          /*
> > >           * Sanitise input arguments.
> > >           * Pages both ends in CMA area could be merged into adjacent unmovable
> > >           * migratetype page by page allocator's buddy algorithm. In the case,
> > >           * you couldn't get a contiguous memory, which is not what we want.
> > >           */
> > >          alignment = max(alignment,  (phys_addr_t)PAGE_SIZE <<
> > >                            max_t(unsigned long, MAX_ORDER - 1, pageblock_order));
> > > 
> > > 
> > > On arm64 with 64K page size and transparent huge page, this gives an alignment
> > > of 512MB. This is quite restrictive and can eat up significant portions of
> > > memory on smaller memory targets. Adjusting the configuration options really
> > > isn't ideal for distributions that aim to have a single image which runs on
> > > all targets.
> > > 
> > > Approaches I've thought about:
> > > - Making CMA alignment less restrictive (and dealing with the fallout from
> > > the comment above)
> > > - Command line option to force a reasonable alignment
> > 
> > Laura, are you still interested discussing this or other CMA related
> > topic?
> > 
> 
> In light of Joonsoo's patches, I don't think we need a lot of time
> but I'd still like some chance to discuss. I think there was some
> other interest in CMA topics so it can be combined with those if
> they are happening as well.

OK, so I've put a placeholder for a CMA discussion. You have won the
lead on that session ;) We can change that later of course.
-- 
Michal Hocko
SUSE Labs
