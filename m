Date: Fri, 2 Feb 2007 03:04:32 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: make mincore work for general mappings
Message-ID: <20070202020432.GA29827@wotan.suse.de>
References: <20070130113720.GA3038@wotan.suse.de> <Pine.LNX.4.64.0701311218390.30567@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0701311218390.30567@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 31, 2007 at 12:20:00PM -0800, Christoph Lameter wrote:
> On Tue, 30 Jan 2007, Nick Piggin wrote:
> 
> > Make mincore work for anon mappings, nonlinear, and migration entries.
> > Based on patch from Linus Torvalds <torvalds@linux-foundation.org>.
> 
> There are certain similarities with /proc/pid/numa_maps. See 
> mm/mempolicy.c. Could we consolidate the code somehow (maybe also with 
> smaps) and have one way of scanning the pages of a process?

smaps and numa_maps are pretty similar in that they are just looking
at the pte_page. mincore is more different in that it looks out to
pagecache and swapcache etc as well, but if the 3 could be unified
nicely it would definitely be worthwhile.

That would be a subsequent patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
