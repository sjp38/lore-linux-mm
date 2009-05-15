Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 608D06B0096
	for <linux-mm@kvack.org>; Fri, 15 May 2009 07:21:19 -0400 (EDT)
Date: Fri, 15 May 2009 13:26:56 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Physical Memory Management [0/1]
Message-ID: <20090515112656.GD16682@one.firstfloor.org>
References: <op.utwwmpsf7p4s8u@amdc030> <1242300002.6642.1091.camel@laptop> <op.utw4fdhz7p4s8u@amdc030> <1242302702.6642.1140.camel@laptop> <op.utw7yhv67p4s8u@amdc030> <20090514100718.d8c20b64.akpm@linux-foundation.org> <1242321000.6642.1456.camel@laptop> <op.utyudge07p4s8u@amdc030> <20090515101811.GC16682@one.firstfloor.org> <op.utyv89ek7p4s8u@amdc030>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <op.utyv89ek7p4s8u@amdc030>
Sender: owner-linux-mm@kvack.org
To: =?utf-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 15, 2009 at 12:47:23PM +0200, MichaA? Nazarewicz wrote:
> On Fri, 15 May 2009 12:18:11 +0200, Andi Kleen wrote:
> > That's not correct, support for multiple huge page sizes was recently
> > added. The interface is a bit clumpsy admittedly, but it's there.
> 
> I'll have to look into that further then.  Having said that, I cannot
> create a huge page SysV shared memory segment with pages of specified
> size, can I?

sysv shared memory supports huge pages, but there is currently
no interface to specify the intended page size, you always
get the default.

> 
> > However for non fragmentation purposes you probably don't
> > want too many different sizes anyways, the more sizes, the worse
> > the fragmentation. Ideal is only a single size.
> 
> Unfortunately, sizes may very from several KiBs to a few MiBs.

Then your approach will likely not be reliable.

> On the other hand, only a handful of apps will use PMM in our system
> and at most two or three will be run at the same time so hopefully
> fragmentation won't be so bad.  But yes, I admit it is a concern.

Such tight restrictions might work for you, but for mainline Linux the quality 
standards are higher.
 
> > As Peter et.al. explained earlier varying buffer sizes don't work
> > anyways.
> 
> Either I missed something or Peter and Adrew only pointed the problem
> we all seem to agree exists: a problem of fragmentation.

Multiple buffer sizes lead to fragmentation.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
