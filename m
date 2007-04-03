Date: Wed, 4 Apr 2007 00:51:55 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: missing madvise functionality
Message-ID: <20070403225155.GA26567@one.firstfloor.org>
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403135154.61e1b5f3.akpm@linux-foundation.org> <4612C059.8070702@redhat.com> <4612C2B6.3010302@cosmosbay.com> <4612CB21.9020005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4612CB21.9020005@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 03, 2007 at 02:46:09PM -0700, Ulrich Drepper wrote:
> Eric Dumazet wrote:
> > A page fault is not that expensive. But clearing N*PAGE_SIZE bytes is,
> > because it potentially evicts a large part of CPU cache.
> 
> *A* page fault is not that expensive.  The problem is that you get a
> page fault for every single page.  For 200k allocated you get 50 page
> faults.  It quickly adds up.

If you know in advance you need them it might be possible to 
batch that. e.g. MADV_WILLNEED could be extended to
work on anonymous memory and establish the mappings in the syscall. 
Would that be useful? 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
