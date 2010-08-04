Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF8D6B0316
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 00:39:12 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o744dD1V029434
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 21:39:13 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by wpaz21.hot.corp.google.com with ESMTP id o744dBwe013171
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 21:39:12 -0700
Received: by pwj9 with SMTP id 9so2526301pwj.27
        for <linux-mm@kvack.org>; Tue, 03 Aug 2010 21:39:11 -0700 (PDT)
Date: Tue, 3 Aug 2010 21:39:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q3 00/23] SLUB: The Unified slab allocator (V3)
In-Reply-To: <20100804024514.139976032@linux.com>
Message-ID: <alpine.DEB.2.00.1008032138160.20049@chino.kir.corp.google.com>
References: <20100804024514.139976032@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, Christoph Lameter wrote:

> The following is a first release of an allocator based on SLAB
> and SLUB that integrates the best approaches from both allocators. The
> per cpu queuing is like the two prior releases. The NUMA facilities
> were much improved vs V2. Shared and alien cache support was added to
> track the cache hot state of objects. 
> 

This insta-reboots on my netperf benchmarking servers (but works with 
numa=off), so I'll have to wait until I can hook up a serial before 
benchmarking this series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
