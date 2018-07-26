Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E72316B000D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:19:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w204-v6so1600157oib.9
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:19:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j133-v6si1046861oia.77.2018.07.26.08.19.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 08:19:49 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6QFJ4g4009886
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:19:49 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kfgduhand-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:19:47 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jul 2018 16:19:00 +0100
Date: Thu, 26 Jul 2018 18:18:53 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 7/7] docs/core-api: mm-api: add section about GFP flags
References: <1532607722-17079-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1532607722-17079-8-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726130106.GC3504@bombadil.infradead.org>
 <20180726142039.GA23627@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726142039.GA23627@dhcp22.suse.cz>
Message-Id: <20180726151852.GF8477@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 26, 2018 at 04:20:39PM +0200, Michal Hocko wrote:
> On Thu 26-07-18 06:01:06, Matthew Wilcox wrote:
> > On Thu, Jul 26, 2018 at 03:22:02PM +0300, Mike Rapoport wrote:
> > > +Memory Allocation Controls
> > > +==========================
> > 
> > Perhaps call this section "Memory Allocation Flags" instead?
> > 
> > > +Linux provides a variety of APIs for memory allocation from direct
> > > +calls to page allocator through slab caches and vmalloc to allocators
> > > +of compressed memory. Although these allocators have different
> > > +semantics and are used in different circumstances, they all share the
> > > +GFP (get free page) flags that control behavior of each allocation
> > > +request.
> > 
> > While this isn't /wrong/, I think it might not be the most useful way
> > of explaining what the GFP flags are to someone who's just come across
> > them in some remote part of the kernel.  How about this paragraph instead?
> > 
> >   Functions which need to allocate memory often use GFP flags to express
> >   how that memory should be allocated.  The GFP acronym stands for "get
> >   free pages", the underlying memory allocation function.
> 
> OK.
> 
> >   Not every GFP
> >   flag is allowed to every function which may allocate memory.  Most
> >   users will want to use a plain ``GFP_KERNEL`` or ``GFP_ATOMIC``.
> 
> Or rather than mentioning the two just use "Useful GFP flag
> combinations" comment segment from gfp.h

The comment there includes GFP_DMA, GFP_NOIO etc so I'd prefer Matthew's
version and maybe even omit GFP_ATOMIC from it.

Some grepping shows that roughly 80% of allocations are GFP_KERNEL, 12% are
GFP_ATOMIC and ... I didn't count the usage of other flags ;-)

> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
