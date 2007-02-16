Date: Thu, 15 Feb 2007 19:36:01 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
In-Reply-To: <20070215191858.1a864874.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702151929180.1696@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
 <20070215171355.67c7e8b4.akpm@linux-foundation.org> <45D50B79.5080002@mbligh.org>
 <20070215174957.f1fb8711.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
 <20070215184800.e2820947.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151849030.1511@schroedinger.engr.sgi.com>
 <20070215191858.1a864874.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, Andrew Morton wrote:

> > Yes ia64 has used the upper 32 bit. However, the lower 32 bits are fully 
> > usable. So we have 32-20 = 12 bits to play with on 64 bit.
> 
> OK.  But not many things are 64-bit-only?

We could restrict some newer features to 64 bits? (ducks and runs ...)

> > None of the above can occur simultaneously.
> The actual implementation details might get messy though.  We can do a
> non-atomic rmw of the three bits but that could corrupt a concurrent
> modification of a different flag.  Or we could do a succession of three
> set_bit/clear_bit operations, but that exposes intermediate invalid states.
> 
> It can be done I guess, but it'd be fiddly.

Right.

Maybe we could somehow splite up page->flags into 4 separate bytes?
Updating one byte would not endanger the other bytes in the other 
sets?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
