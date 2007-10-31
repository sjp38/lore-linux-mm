Subject: Re: [PATCH 03/33] mm: slub: add knowledge of reserve pages
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1193835258.27652.199.camel@twins>
References: <20071030160401.296770000@chello.nl>
	 <200710312146.03351.nickpiggin@yahoo.com.au>
	 <1193833072.27652.167.camel@twins>
	 <200710312225.07249.nickpiggin@yahoo.com.au>
	 <1193835258.27652.199.camel@twins>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 14:08:43 +0100
Message-Id: <1193836123.27652.209.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-31 at 13:54 +0100, Peter Zijlstra wrote:
> On Wed, 2007-10-31 at 22:25 +1100, Nick Piggin wrote:

> > What I'm saying is that the slab allocator slowpath should always
> > just check watermarks against the current task. Instead of this
> > ->reserve stuff.
> 
> So what you say is to allocate a slab every time we take the slow path,
> even when we already have one?

BTW, a task that does not have reserve permissions will already attempt
to allocate a new slab - this is done to probe the current watermarks.
If this succeeds the reserve status is lifted.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
