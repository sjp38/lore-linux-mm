Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id D01646B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 09:59:55 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id t63so13433151ywa.11
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 06:59:55 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c25si2531863qtc.109.2018.01.31.06.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 06:59:54 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0VExm2p121461
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 09:59:54 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fud3ysa9f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 09:59:53 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 31 Jan 2018 14:59:50 -0000
Date: Wed, 31 Jan 2018 16:59:46 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [LSF/MM TOPIC] mm documentation
References: <20180130105237.GB7201@rapoport-lnx>
 <20180130105450.GC7201@rapoport-lnx>
 <20180130115055.GZ21609@dhcp22.suse.cz>
 <20180130125443.GA21333@rapoport-lnx>
 <20180130134141.GD21609@dhcp22.suse.cz>
 <20180130142849.GD21333@rapoport-lnx>
 <20180131023838.GA28275@bombadil.infradead.org>
 <20180131090037.GQ21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180131090037.GQ21609@dhcp22.suse.cz>
Message-Id: <20180131145945.GB20535@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Wed, Jan 31, 2018 at 10:00:37AM +0100, Michal Hocko wrote:
> On Tue 30-01-18 18:38:38, Matthew Wilcox wrote:
> > On Tue, Jan 30, 2018 at 04:28:50PM +0200, Mike Rapoport wrote:
> > > On Tue, Jan 30, 2018 at 02:41:41PM +0100, Michal Hocko wrote:
> > > > It is good to hear that at least something has a documentation coverage.
> > > > I was asking mostly because I _think_ that the API documentation is far
> > > > from the top priority. 
> > > 
> > > API documentations is important for kernel developers who are not deeply
> > > involved with mm. When one develops a device driver, knowing how to
> > > allocate and free memory is essential. And, while *malloc are included in
> > > kernel-api.rst, CMA and HMM documentation is not visible.
> > > 
> > > > We are seriously lacking any highlevel one which describes the design and
> > > > subsytems interaction.
> > > 
> > > I should have describe it better, but by "creating a new structure for mm
> > > documentation" I've also meant adding high level description.
> > 
> > We should be really clear what kind of documentation we're trying to create.
> > 
> > There are four distinct types of documentation which would be useful:
> > 
> >  - How, when and why to use the various function calls and their
> >    parameters from the perspective of a user outside the mm/ hierarchy.
> >    Device driver authors, filesystem authors and others of their ilk.
> >  - The overall philosophy and structure of the mm directory, what it does,
> >    why it does it, perhaps even outlines of abandoned approaches.
> >  - What functionality the mm subsystem requires from others.  For example,
> >    what does the mm rely on from the CPU architectures (and maybe it would
> >    make sense to also include services the mm layer provides to arches in
> >    this section, like setting up sparsemem).
> 
> yes
> 
> >  - How to tweak the various knobs that the mm subsystem provides.
> >    Maybe this is all adequately documented elsewhere already.
> 
> This would be Documentation/sysctl/vm.txt which is one that is at least
> close to be complete.
> 
> > Perhaps others can think of other types of documentation which would
> > be useful.
> 
> - design documentation of various parts of the MM - reclaim, memory
>   hotplug, memcg, page allocator, memory models, THP, rmap code (you
>   name it)
> 
> > That shouldn't detract from my main point, which is that
> > saying "Now we have mm documentation" is laudable, but not enough.
> 
> Absolutely agreed.

I don't think anybody is saying "we have mm documentation", at least in the
sense "mm is well documented".

One of my points was that bringing some order to the existing bits of the
documentation is an important step forward and it does not contradict
necessity to add documentation you and Matthew described here.

> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
