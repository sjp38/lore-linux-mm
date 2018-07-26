Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05B496B000A
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:41:54 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i24-v6so1079769edq.16
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 09:41:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6-v6si1061956edb.59.2018.07.26.09.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 09:41:52 -0700 (PDT)
Date: Thu, 26 Jul 2018 18:41:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 7/7] docs/core-api: mm-api: add section about GFP flags
Message-ID: <20180726164150.GO28386@dhcp22.suse.cz>
References: <1532607722-17079-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1532607722-17079-8-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726130106.GC3504@bombadil.infradead.org>
 <20180726142039.GA23627@dhcp22.suse.cz>
 <20180726151852.GF8477@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726151852.GF8477@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 26-07-18 18:18:53, Mike Rapoport wrote:
> On Thu, Jul 26, 2018 at 04:20:39PM +0200, Michal Hocko wrote:
> > On Thu 26-07-18 06:01:06, Matthew Wilcox wrote:
> > > On Thu, Jul 26, 2018 at 03:22:02PM +0300, Mike Rapoport wrote:
> > > > +Memory Allocation Controls
> > > > +==========================
> > > 
> > > Perhaps call this section "Memory Allocation Flags" instead?
> > > 
> > > > +Linux provides a variety of APIs for memory allocation from direct
> > > > +calls to page allocator through slab caches and vmalloc to allocators
> > > > +of compressed memory. Although these allocators have different
> > > > +semantics and are used in different circumstances, they all share the
> > > > +GFP (get free page) flags that control behavior of each allocation
> > > > +request.
> > > 
> > > While this isn't /wrong/, I think it might not be the most useful way
> > > of explaining what the GFP flags are to someone who's just come across
> > > them in some remote part of the kernel.  How about this paragraph instead?
> > > 
> > >   Functions which need to allocate memory often use GFP flags to express
> > >   how that memory should be allocated.  The GFP acronym stands for "get
> > >   free pages", the underlying memory allocation function.
> > 
> > OK.
> > 
> > >   Not every GFP
> > >   flag is allowed to every function which may allocate memory.  Most
> > >   users will want to use a plain ``GFP_KERNEL`` or ``GFP_ATOMIC``.
> > 
> > Or rather than mentioning the two just use "Useful GFP flag
> > combinations" comment segment from gfp.h
> 
> The comment there includes GFP_DMA, GFP_NOIO etc so I'd prefer Matthew's
> version and maybe even omit GFP_ATOMIC from it.
> 
> Some grepping shows that roughly 80% of allocations are GFP_KERNEL, 12% are
> GFP_ATOMIC and ... I didn't count the usage of other flags ;-)

Well, I will certainly not insist... I don't know who is the expected
audience of this documentation. That section was meant for kernel
developers to know which of the high level flags to use.
-- 
Michal Hocko
SUSE Labs
