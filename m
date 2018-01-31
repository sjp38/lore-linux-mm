Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E35F6B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 04:00:39 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d63so1864354wma.4
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 01:00:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e191si10731167wme.159.2018.01.31.01.00.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 01:00:38 -0800 (PST)
Date: Wed, 31 Jan 2018 10:00:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] mm documentation
Message-ID: <20180131090037.GQ21609@dhcp22.suse.cz>
References: <20180130105237.GB7201@rapoport-lnx>
 <20180130105450.GC7201@rapoport-lnx>
 <20180130115055.GZ21609@dhcp22.suse.cz>
 <20180130125443.GA21333@rapoport-lnx>
 <20180130134141.GD21609@dhcp22.suse.cz>
 <20180130142849.GD21333@rapoport-lnx>
 <20180131023838.GA28275@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180131023838.GA28275@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue 30-01-18 18:38:38, Matthew Wilcox wrote:
> On Tue, Jan 30, 2018 at 04:28:50PM +0200, Mike Rapoport wrote:
> > On Tue, Jan 30, 2018 at 02:41:41PM +0100, Michal Hocko wrote:
> > > It is good to hear that at least something has a documentation coverage.
> > > I was asking mostly because I _think_ that the API documentation is far
> > > from the top priority. 
> > 
> > API documentations is important for kernel developers who are not deeply
> > involved with mm. When one develops a device driver, knowing how to
> > allocate and free memory is essential. And, while *malloc are included in
> > kernel-api.rst, CMA and HMM documentation is not visible.
> > 
> > > We are seriously lacking any highlevel one which describes the design and
> > > subsytems interaction.
> > 
> > I should have describe it better, but by "creating a new structure for mm
> > documentation" I've also meant adding high level description.
> 
> We should be really clear what kind of documentation we're trying to create.
> 
> There are four distinct types of documentation which would be useful:
> 
>  - How, when and why to use the various function calls and their
>    parameters from the perspective of a user outside the mm/ hierarchy.
>    Device driver authors, filesystem authors and others of their ilk.
>  - The overall philosophy and structure of the mm directory, what it does,
>    why it does it, perhaps even outlines of abandoned approaches.
>  - What functionality the mm subsystem requires from others.  For example,
>    what does the mm rely on from the CPU architectures (and maybe it would
>    make sense to also include services the mm layer provides to arches in
>    this section, like setting up sparsemem).

yes

>  - How to tweak the various knobs that the mm subsystem provides.
>    Maybe this is all adequately documented elsewhere already.

This would be Documentation/sysctl/vm.txt which is one that is at least
close to be complete.
 
> Perhaps others can think of other types of documentation which would
> be useful.

- design documentation of various parts of the MM - reclaim, memory
  hotplug, memcg, page allocator, memory models, THP, rmap code (you
  name it)

> That shouldn't detract from my main point, which is that
> saying "Now we have mm documentation" is laudable, but not enough.

Absolutely agreed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
