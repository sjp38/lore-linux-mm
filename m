Date: Wed, 4 Apr 2007 13:54:58 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: missing madvise functionality
Message-Id: <20070404135458.4f1a7059.dada1@cosmosbay.com>
In-Reply-To: <46137882.6050708@yahoo.com.au>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403202937.GE355@devserv.devel.redhat.com>
	<20070403144948.fe8eede6.akpm@linux-foundation.org>
	<4612DCC6.7000504@cosmosbay.com>
	<46130BC8.9050905@yahoo.com.au>
	<1175675146.6483.26.camel@twins>
	<461367F6.10705@yahoo.com.au>
	<20070404113447.17ccbefa.dada1@cosmosbay.com>
	<46137882.6050708@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 04 Apr 2007 20:05:54 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> > @@ -1638,7 +1652,7 @@ find_extend_vma(struct mm_struct * mm, u
> >  	unsigned long start;
> >  
> >  	addr &= PAGE_MASK;
> > -	vma = find_vma(mm,addr);
> > +	vma = find_vma(mm,addr,&current->vmacache);
> >  	if (!vma)
> >  		return NULL;
> >  	if (vma->vm_start <= addr)
> 
> So now you can have current calling find_extend_vma on someone else's mm
> but using their cache. So you're going to return current's vma, or current
> is going to get one of mm's vmas in its cache :P

This was not a working patch, just to throw the idea, since the answers I got showed I was not understood.

In this case, find_extend_vma() should of course have one struct vm_area_cache * argument, like find_vma()

One single cache on one mm is not scalable. oprofile badly hits it on a dual cpu config.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
