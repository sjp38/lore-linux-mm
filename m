Date: Mon, 16 Oct 2006 03:26:32 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [TAKE] memory page_alloc zonelist caching speedup
Message-Id: <20061016032632.486f4235.pj@sgi.com>
In-Reply-To: <200610161134.07168.ak@suse.de>
References: <20061010081429.15156.77206.sendpatchset@jackhammer.engr.sgi.com>
	<200610161134.07168.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, rientjes@google.com, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Andi wrote:
> I think some more precise numbers would be appreciated before doing
> such changes.

Aren't there more precise numbers further down in the message to which
you were responding?

> Yes but you will add latencies for cache line bounces won't you?
> The old zone lists were completely read only. That is what worries me 
> most.

There is one zonelist_cache per node, added at the end of the regular
zonelist array for each node.  It will have a few words updated
typically at the rate of once per second by the CPUs sharing that node.

>From what my tests showed, and from what I'd expect, updating a few
node local words per second is not a problem.

If you have a particular architecture in mind for which the tradeoffs
in the proposed patch don't seem right, could you spell out that
architecture a bit, so we can sensibly consider whether some
refinements to this patch will suit that architecture better?

Certainly, from the numbers that I have, and by private email that
Rohit Seth has on a different architecture, this patch is neutral or a
win for the cases we considered, depending on the degree of node
locality of the memory accesses.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
