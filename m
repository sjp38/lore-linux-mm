Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2822A6B02A5
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 12:17:48 -0400 (EDT)
Date: Wed, 4 Aug 2010 11:17:47 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q3 00/23] SLUB: The Unified slab allocator (V3)
In-Reply-To: <alpine.DEB.2.00.1008032138160.20049@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008041115500.11084@router.home>
References: <20100804024514.139976032@linux.com> <alpine.DEB.2.00.1008032138160.20049@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, David Rientjes wrote:

> On Tue, 3 Aug 2010, Christoph Lameter wrote:
>
> > The following is a first release of an allocator based on SLAB
> > and SLUB that integrates the best approaches from both allocators. The
> > per cpu queuing is like the two prior releases. The NUMA facilities
> > were much improved vs V2. Shared and alien cache support was added to
> > track the cache hot state of objects.
> >
>
> This insta-reboots on my netperf benchmarking servers (but works with
> numa=off), so I'll have to wait until I can hook up a serial before
> benchmarking this series.

There are potential issues with

1. The size of per cpu reservation on bootup and the new percpu code that
allows allocations for per cpu areas during bootup. Sometime I wonder if I
should just go back to static allocs for that.

2. The topology information provided by the machine for the cache setup.

3. My code of course.

Bootlog would be appreciated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
