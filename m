Date: Tue, 3 Apr 2007 14:16:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: missing madvise functionality
Message-Id: <20070403141656.1e25b878.akpm@linux-foundation.org>
In-Reply-To: <4612C059.8070702@redhat.com>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403135154.61e1b5f3.akpm@linux-foundation.org>
	<4612C059.8070702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 03 Apr 2007 17:00:09 -0400
Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> 
> > Oh.  I was assuming that we'd want to unmap these pages from pagetables and
> > mark then super-easily-reclaimable.  So a later touch would incur a minor
> > fault.
> > 
> > But you think that we should leave them mapped into pagetables so no such
> > fault occurs.
> 
> > Leaving the pages mapped into pagetables means that they are considerably
> > less likely to be reclaimed.
> 
> If we move the pages to a place where they are very likely to be
> reclaimed quickly (end of the inactive list, or a separate
> reclaim list) and clear the dirty and referenced lists, we can
> both reclaim the page easily *and* avoid the page fault penalty.
> 

ah, yes, you're right.  That part should work nicely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
