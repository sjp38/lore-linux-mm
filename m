Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6E5396B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 11:56:51 -0400 (EDT)
Date: Wed, 6 Oct 2010 10:56:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1010061054410.31538@router.home>
References: <20101005185725.088808842@linux.com> <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010, Pekka Enberg wrote:

> Are there any stability problems left? Have you tried other benchmarks
> (e.g. hackbench, sysbench)? Can we merge the series in smaller
> batches? For example, if we leave out the NUMA parts in the first
> stage, do we expect to see performance regressions?

I have tried hackbench but the number seem to be unstable on my system.
There may be various small optimizations still left to be done.

You cannot merge this without the patches up to the patch that implements
alien caches without performance issues. If you leave out the NUMA parts
then !NUMA is of course fine.

I would suggest to merge the cleanups first for the next upstream
merge cycle and give this patchset at least a whole -next cycle before
upstream merge.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
