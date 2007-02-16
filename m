Date: Thu, 15 Feb 2007 18:50:39 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
In-Reply-To: <20070215184800.e2820947.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702151849030.1511@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
 <20070215171355.67c7e8b4.akpm@linux-foundation.org> <45D50B79.5080002@mbligh.org>
 <20070215174957.f1fb8711.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
 <20070215184800.e2820947.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, Andrew Morton wrote:

> We discussed that a while back and iirc ia64 has gone and gobbled most of
> the upper 32bits.  Someone went and added some ascii art around the
> PG_uncached definition but it is incomprehensible.  It seems to claim that
> ia64 has gone and used all 32 bits, dammit.  If so, some adjustments to
> ia64 might be called for.

Yes ia64 has used the upper 32 bit. However, the lower 32 bits are fully 
usable. So we have 32-20 = 12 bits to play with on 64 bit.
> 
> > page_type = { SLAB, LRU, MLOCK, RESERVED, BUDDY, <add 3 more types here> }
> 
> Yeah, maybe.  There doesn't seem to be a lot of room for that though - a
> lot of those flags are quite independent and can occur simultaneously.

None of the above can occur simultaneously.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
