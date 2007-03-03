Date: Fri, 2 Mar 2007 17:58:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070302175856.bb9de72d.akpm@linux-foundation.org>
In-Reply-To: <20070303014004.GC23573@holomorphy.com>
References: <20070302100619.cec06d6a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703021012170.17676@schroedinger.engr.sgi.com>
	<45E86BA0.50508@redhat.com>
	<20070302211207.GJ10643@holomorphy.com>
	<45E894D7.2040309@redhat.com>
	<20070302135243.ada51084.akpm@linux-foundation.org>
	<45E89F1E.8020803@redhat.com>
	<20070302142256.0127f5ac.akpm@linux-foundation.org>
	<45E8A677.7000205@redhat.com>
	<20070302145906.653d3b82.akpm@linux-foundation.org>
	<20070303014004.GC23573@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@redhat.com>, Bill Irwin <bill.irwin@oracle.com>, Christoph Lameter <clameter@engr.sgi.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007 17:40:04 -0800
William Lee Irwin III <wli@holomorphy.com> wrote:

> On Fri, Mar 02, 2007 at 02:59:06PM -0800, Andrew Morton wrote:
> > Somehow I don't believe that a person or organisation which is incapable of
> > preparing even a simple testcase will be capable of fixing problems such as
> > this without breaking things.
> 
> My gut feeling is to agree, but I get nagging doubts when I try to
> think of how to boil things like [major benchmarks whose names are
> trademarked/copyrighted/etc. censored] down to simple testcases. Some
> other things are obvious but require vast resources, like zillions of
> disks fooling throttling/etc. heuristics of ancient downrev kernels.

noooooooooo.  You're approaching it from the wrong direction.

Step 1 is to understand what is happening on the affected production
system.  Completely.  Once that is fully understood then it is a relatively
simple matter to concoct a test case which triggers the same failure mode.

It is very hard to go the other way: to poke around with various stress
tests which you think are doing something similar to what you think the
application does in the hope that similar symptoms will trigger so you can
then work out what the kernel is doing.  yuk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
