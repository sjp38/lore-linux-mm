Subject: Re: Superpages Project  -  sourceforge.net/projects/linuxsuperpages
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <F9E7AD49A6823D4AA5A36E1DE32F0F9B27570B8CBC@GVW1092EXB.americas.hpqcorp.net>
References: <F9E7AD49A6823D4AA5A36E1DE32F0F9B27570B8CBC@GVW1092EXB.americas.hpqcorp.net>
Content-Type: text/plain
Date: Wed, 15 Oct 2008 15:00:47 +0200
Message-Id: <1224075647.28131.6.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Wildman, Tom" <tom.wildman@hp.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "alan@redhat.com" <alan@redhat.com>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-10-15 at 01:51 +0000, Wildman, Tom wrote:
> A new project has been created at SourceForge with an implementation
> of the Rice University's Superpages FreeBSD prototype that has been
> ported to the 2.6 Linux kernel for IA64, x86-64, and x86-32.
> 
> The project can be found at:
> http://sourceforge.net/projects/linuxsuperpages
> 
> The major benefit of supporting Superpages is increased memory reach
> of the processor's TLB, which reduces the number of TLB misses in
> applications that have large data sets.  Some benchmarks have been
> improved 20% in execution time.
> 
> Reference www.cs.rice.edu/~jnavarro/superpages/ for more information
> about the Rice University's Superpages project.
> 
> The project is being made available to the Open Source community to
> share the implementation and knowledge.  With the enhancements to the
> x86 architectures to support multiple and large page sizes there
> should be increased interest in this functionality.

How are you proposing to address the fun issues like online compaction
etc. ?

Furthermore, what's the added advantage of dynamic superpages over
exlpicit superpage support, eg. though the use of libhugetlb?

Unless you realize online compaction and add a kind of extend allocation
to the page allocator there will hardly ever be a situation where you
can promote a page.

All of which is rather expensive to do, changing the application might
be easier and deliver better performance gains.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
