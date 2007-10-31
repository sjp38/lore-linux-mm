From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 03/33] mm: slub: add knowledge of reserve pages
Date: Wed, 31 Oct 2007 22:25:06 +1100
References: <20071030160401.296770000@chello.nl> <200710312146.03351.nickpiggin@yahoo.com.au> <1193833072.27652.167.camel@twins>
In-Reply-To: <1193833072.27652.167.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710312225.07249.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wednesday 31 October 2007 23:17, Peter Zijlstra wrote:
> On Wed, 2007-10-31 at 21:46 +1100, Nick Piggin wrote:

> > And I'd prevent these ones from doing so.
> >
> > Without keeping track of "reserve" pages, which doesn't feel
> > too clean.
>
> The problem with that is that once a slab was allocated with the right
> allocation context, anybody can get objects from these slabs.

[snip]

I understand that.


> So we either reserve a page per object, which for 32 byte objects is a
> large waste, or we stop anybody who doesn't have the right permissions
> from obtaining objects. I took the latter approach.

What I'm saying is that the slab allocator slowpath should always
just check watermarks against the current task. Instead of this
->reserve stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
