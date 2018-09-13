Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C27EB8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 08:39:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z11-v6so4033557wma.4
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 05:39:55 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s17-v6si3677927wra.350.2018.09.13.05.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Sep 2018 05:39:54 -0700 (PDT)
Date: Thu, 13 Sep 2018 14:39:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
Message-ID: <20180913123937.GX24124@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
 <20180913092811.894806629@infradead.org>
 <20180913123014.0d9321b8@mschwideX1>
 <20180913105738.GW24124@hirez.programming.kicks-ass.net>
 <20180913141827.1776985e@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180913141827.1776985e@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Thu, Sep 13, 2018 at 02:18:27PM +0200, Martin Schwidefsky wrote:
> We may get something working with a common code mmu_gather, but I fear the
> day someone makes a "minor" change to that subtly break s390. The debugging of
> TLB related problems is just horrible..

Yes it is, not just on s390 :/

And this is not something that's easy to write sanity checks for either
AFAIK. I mean we can do a few multi-threaded mmap()/mprotect()/munmap()
proglets and catch faults, but that doesn't even get close to covering
all the 'fun' spots.

Then again, you're more than welcome to the new:

  MMU GATHER AND TLB INVALIDATION

section in MAINTAINERS.
