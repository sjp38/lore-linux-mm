Date: Mon, 19 Jun 2006 15:27:04 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH] inactive_clean
In-Reply-To: <Pine.LNX.4.64.0606191223410.3925@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0606191526401.6565@cuia.boston.redhat.com>
References: <1150719606.28517.83.camel@lappy>
 <Pine.LNX.4.64.0606190837450.1184@schroedinger.engr.sgi.com>
 <1150740624.28517.108.camel@lappy> <Pine.LNX.4.64.0606191202350.23422@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0606191509490.6565@cuia.boston.redhat.com>
 <Pine.LNX.4.64.0606191223410.3925@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, Nick Piggin <piggin@cyberone.com.au>, linux-mm <linux-mm@kvack.org>, Nikita Danilov <nikita@clusterfs.com>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2006, Christoph Lameter wrote:
> On Mon, 19 Jun 2006, Rik van Riel wrote:
> 
> > Not only swap.   Writable MAP_SHARED mmap has the same problem...
> 
> Writable MAP_SHARED is throttled by Peter Z. other patchset on page 
> dirtying. So the problem should have been solved at that level.

This new patch throttles both.   It might even make the other
one less needed - not sure...

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
