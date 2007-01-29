Subject: Re: [PATCH 00/14] Concurrent Page Cache
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0701291013530.29254@schroedinger.engr.sgi.com>
References: <20070128131343.628722000@programming.kicks-ass.net>
	 <Pine.LNX.4.64.0701290918260.28330@schroedinger.engr.sgi.com>
	 <1170093944.6189.192.camel@twins>
	 <Pine.LNX.4.64.0701291013530.29254@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 29 Jan 2007 19:56:17 +0100
Message-Id: <1170096978.10987.39.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-01-29 at 10:15 -0800, Christoph Lameter wrote:
> On Mon, 29 Jan 2007, Peter Zijlstra wrote:
> 
> > Ladder locking would end up:
> > 
> > lock A0
> > lock B1
> > unlock A0 -> a new operation can start
> > lock C2
> > unlock B1
> > lock D5
> > unlock C2
> > ** we do stuff to D5
> > unlock D5
> > 
> 
> Instead of taking one lock we would need to take 4?

Yep.

> Wont doing so cause significant locking overhead?
> We probably would want to run some benchmarks. 

Right, I was hoping the extra locking overhead would be more than
compensated by the reduction in lock contention time. But testing is
indeed in order.

> Maybe disable the scheme for systems with a small number of 
> processors?

CONFIG_RADIX_TREE_CONCURRENT does exactly this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
