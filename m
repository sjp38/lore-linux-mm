Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3CA6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 21:38:42 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e28so9415483pgn.23
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 18:38:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s10si10232724pgv.654.2018.01.30.18.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Jan 2018 18:38:40 -0800 (PST)
Date: Tue, 30 Jan 2018 18:38:38 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] mm documentation
Message-ID: <20180131023838.GA28275@bombadil.infradead.org>
References: <20180130105237.GB7201@rapoport-lnx>
 <20180130105450.GC7201@rapoport-lnx>
 <20180130115055.GZ21609@dhcp22.suse.cz>
 <20180130125443.GA21333@rapoport-lnx>
 <20180130134141.GD21609@dhcp22.suse.cz>
 <20180130142849.GD21333@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130142849.GD21333@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, Jan 30, 2018 at 04:28:50PM +0200, Mike Rapoport wrote:
> On Tue, Jan 30, 2018 at 02:41:41PM +0100, Michal Hocko wrote:
> > It is good to hear that at least something has a documentation coverage.
> > I was asking mostly because I _think_ that the API documentation is far
> > from the top priority. 
> 
> API documentations is important for kernel developers who are not deeply
> involved with mm. When one develops a device driver, knowing how to
> allocate and free memory is essential. And, while *malloc are included in
> kernel-api.rst, CMA and HMM documentation is not visible.
> 
> > We are seriously lacking any highlevel one which describes the design and
> > subsytems interaction.
> 
> I should have describe it better, but by "creating a new structure for mm
> documentation" I've also meant adding high level description.

We should be really clear what kind of documentation we're trying to create.

There are four distinct types of documentation which would be useful:

 - How, when and why to use the various function calls and their
   parameters from the perspective of a user outside the mm/ hierarchy.
   Device driver authors, filesystem authors and others of their ilk.
 - The overall philosophy and structure of the mm directory, what it does,
   why it does it, perhaps even outlines of abandoned approaches.
 - What functionality the mm subsystem requires from others.  For example,
   what does the mm rely on from the CPU architectures (and maybe it would
   make sense to also include services the mm layer provides to arches in
   this section, like setting up sparsemem).
 - How to tweak the various knobs that the mm subsystem provides.
   Maybe this is all adequately documented elsewhere already.

Perhaps others can think of other types of documentation which would
be useful.  That shouldn't detract from my main point, which is that
saying "Now we have mm documentation" is laudable, but not enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
