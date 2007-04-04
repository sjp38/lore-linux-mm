Subject: Re: missing madvise functionality
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <46130BC8.9050905@yahoo.com.au>
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>
	 <46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>
	 <20070403125903.3e8577f4.akpm@linux-foundation.org>
	 <4612B645.7030902@redhat.com>
	 <20070403202937.GE355@devserv.devel.redhat.com>
	 <20070403144948.fe8eede6.akpm@linux-foundation.org>
	 <4612DCC6.7000504@cosmosbay.com>  <46130BC8.9050905@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 04 Apr 2007 10:25:46 +0200
Message-Id: <1175675146.6483.26.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 12:22 +1000, Nick Piggin wrote:
> Eric Dumazet wrote:

> > I do think such workloads might benefit from a vma_cache not shared by 
> > all threads but private to each thread. A sequence could invalidate the 
> > cache(s).
> > 
> > ie instead of a mm->mmap_cache, having a mm->sequence, and each thread 
> > having a current->mmap_cache and current->mm_sequence
> 
> I have a patchset to do exactly this, btw.

/me too

However, I decided against pushing it because when it does happen that a
task is not involved with a vma lookup for longer than it takes the seq
count to wrap we have a stale pointer...

We could go and walk the tasks once in a while to reset the pointer, but
it all got a tad involved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
