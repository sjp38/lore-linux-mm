From: Andi Kleen <ak@suse.de>
Subject: Re: Page allocator: Single Zone optimizations
Date: Fri, 3 Nov 2006 23:19:53 +0100
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com> <20061103135013.6bdc6240.akpm@osdl.org> <Pine.LNX.4.64.0611031352420.16486@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611031352420.16486@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200611032319.53888.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

> This has to do with the constructors and the destructors. They are only 
> applied during the first allocation or the final deallocation of the slab. 

It's pretty much obsolete though - nearly nobody uses constructors/destructors.
And the few uses left over are useless to avoid cache misses 
and could as well be removed.

Long ago i fixed some code to use constructors and made sure it carefully
avoided some cache misses in the hot path, but typically when people change
anything later they destroy that. It's just not maintainable.

I would vote for just getting rid of slab constructors/destructors.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
