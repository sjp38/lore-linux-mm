Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 4770E6B0093
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 18:53:38 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so22055293pbb.14
        for <linux-mm@kvack.org>; Sun, 08 Jul 2012 15:53:37 -0700 (PDT)
Date: Sun, 8 Jul 2012 15:53:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: don't invoke __alloc_pages_direct_compact when order
 0
In-Reply-To: <CAAmzW4PXdpQ2zSnkx8sSScAt1OY0j4+HXVmf=COvP7eMLqrEvQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207081547140.18461@chino.kir.corp.google.com>
References: <1341588521-17744-1-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207070139510.10445@chino.kir.corp.google.com> <CAAmzW4PXdpQ2zSnkx8sSScAt1OY0j4+HXVmf=COvP7eMLqrEvQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 8 Jul 2012, JoonSoo Kim wrote:

> >> __alloc_pages_direct_compact has many arguments so invoking it is very costly.
> >> And in almost invoking case, order is 0, so return immediately.
> >>
> >
> > If "zero cost" is "very costly", then this might make sense.
> >
> > __alloc_pages_direct_compact() is inlined by gcc.
> 
> In my kernel image, __alloc_pages_direct_compact() is not inlined by gcc.

Adding Andrew and Mel to the thread since this would require that we 
revert 11e33f6a55ed ("page allocator: break up the allocator entry point 
into fast and slow paths") which would obviously not be a clean revert 
since there have been several changes to these functions over the past 
three years.

I'm stunned (and skeptical) that __alloc_pages_direct_compact() is not 
inlined by your gcc, especially since the kernel must be compiled with 
optimization (either -O1 or -O2 which causes these functions to be 
inlined).  What version of gcc are you using and on what architecture?  
Please do "make mm/page_alloc.s" and send it to me privately, I'll file 
this and fix it up on gcc-bugs.

I'll definitely be following up on this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
