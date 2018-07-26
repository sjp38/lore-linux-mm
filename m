Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9E436B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:36:12 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n4-v6so1213947pgp.8
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:36:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x68-v6si1570117pfc.239.2018.07.26.08.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Jul 2018 08:36:11 -0700 (PDT)
Date: Thu, 26 Jul 2018 08:36:05 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 7/7] docs/core-api: mm-api: add section about GFP flags
Message-ID: <20180726153605.GB27612@bombadil.infradead.org>
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
Cc: Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 26, 2018 at 06:18:53PM +0300, Mike Rapoport wrote:
> On Thu, Jul 26, 2018 at 04:20:39PM +0200, Michal Hocko wrote:
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

I'm totally OK with that.

> Some grepping shows that roughly 80% of allocations are GFP_KERNEL, 12% are
> GFP_ATOMIC and ... I didn't count the usage of other flags ;-)

;-)  You'll find a lot of GFP_NOFS and GFP_NOIO in the filesystem/block
code ...
