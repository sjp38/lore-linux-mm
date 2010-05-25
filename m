Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 431656008F9
	for <linux-mm@kvack.org>; Tue, 25 May 2010 06:02:36 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o4PA2Wf5001290
	for <linux-mm@kvack.org>; Tue, 25 May 2010 03:02:32 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by kpbe11.cbf.corp.google.com with ESMTP id o4PA2UIb016012
	for <linux-mm@kvack.org>; Tue, 25 May 2010 03:02:30 -0700
Received: by pzk3 with SMTP id 3so2502905pzk.26
        for <linux-mm@kvack.org>; Tue, 25 May 2010 03:02:30 -0700 (PDT)
Date: Tue, 25 May 2010 03:02:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
In-Reply-To: <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1005250257100.8045@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com> <20100524070309.GU2516@laptop> <alpine.DEB.2.00.1005240852580.5045@router.home> <20100525020629.GA5087@laptop> <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com> <20100525070734.GC5087@laptop>
 <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2010, Pekka Enberg wrote:

> I wouldn't say it's a nightmare, but yes, it could be better. From my
> point of view SLUB is the base of whatever the future will be because
> the code is much cleaner and simpler than SLAB.

The code may be much cleaner and simpler than slab, but nobody (to date) 
has addressed the significant netperf TCP_RR regression that slub has, for 
example.  I worked on a patchset to do that for a while but it wasn't 
popular because it added some increments to the fastpath for tracking 
data.

I think it's great to have clean and simple code, but even considering its 
use is a non-starter when the entire kernel is significantly slower for 
certain networking loads.

> That's why I find
> Christoph's work on SLEB more interesting than SLQB, for example,
> because it's building on top of something that's mature and stable.
> 
> That said, are you proposing that even without further improvements to
> SLUB, we should go ahead and, for example, remove SLAB from Kconfig
> for v2.6.36 and see if we can just delete the whole thing from, say,
> v2.6.38?
> 

We use slab internally specifically because of the slub regressions.  
Removing it from the kernel at this point would be the equivalent of 
saying that Linux cares about certain workloads more than others since 
there are clearly benchmarks that show slub to be inferior in pure 
performance numbers.  I'd love for us to switch to slub but we can't take 
the performance hit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
