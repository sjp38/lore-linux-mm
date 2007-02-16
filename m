Date: Thu, 15 Feb 2007 20:07:04 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
In-Reply-To: <20070215200204.899811b4.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702152005130.1696@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
 <20070215171355.67c7e8b4.akpm@linux-foundation.org> <45D50B79.5080002@mbligh.org>
 <20070215174957.f1fb8711.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
 <20070215184800.e2820947.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151849030.1511@schroedinger.engr.sgi.com>
 <20070215191858.1a864874.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151929180.1696@schroedinger.engr.sgi.com>
 <20070215194258.a354f428.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151945090.1696@schroedinger.engr.sgi.com>
 <20070215200204.899811b4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, Andrew Morton wrote:

> > could be used instead? For 1G of memory we would need 
> > 
> > 2^(30 - PAGE_SHIFT / 8 = 2^(30-12-3) = 2^15 = 32k bytes of a bitmap.
> > 
> > Seems to be reasonable?
> > 
> 
> 32k per bit per gig, yes.  Better for large PAGE_SIZE.  More cachemisses.
> 
> But will it come unstuck for machines which have a super-sparse pfn space?

IA64 is such a beast. I think IA64 would work fine if we had bitmap 
vectors per zone. However, powerpc may have even super sparse zones. We 
may have to ask them first.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
