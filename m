Date: Fri, 2 Mar 2007 14:22:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070302142256.0127f5ac.akpm@linux-foundation.org>
In-Reply-To: <45E89F1E.8020803@redhat.com>
References: <20070301101249.GA29351@skynet.ie>
	<20070301160915.6da876c5.akpm@linux-foundation.org>
	<45E842F6.5010105@redhat.com>
	<20070302085838.bcf9099e.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703020919350.16719@schroedinger.engr.sgi.com>
	<20070302093501.34c6ef2a.akpm@linux-foundation.org>
	<45E8624E.2080001@redhat.com>
	<20070302100619.cec06d6a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703021012170.17676@schroedinger.engr.sgi.com>
	<45E86BA0.50508@redhat.com>
	<20070302211207.GJ10643@holomorphy.com>
	<45E894D7.2040309@redhat.com>
	<20070302135243.ada51084.akpm@linux-foundation.org>
	<45E89F1E.8020803@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Bill Irwin <bill.irwin@oracle.com>, Christoph Lameter <clameter@engr.sgi.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 02 Mar 2007 17:03:10 -0500
Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> > On Fri, 02 Mar 2007 16:19:19 -0500
> > Rik van Riel <riel@redhat.com> wrote:
> >> Bill Irwin wrote:
> >>> On Fri, Mar 02, 2007 at 01:23:28PM -0500, Rik van Riel wrote:
> >>>> With 32 CPUs diving into the page reclaim simultaneously,
> >>>> each trying to scan a fraction of memory, this is disastrous
> >>>> for performance.  A 256GB system should be even worse.
> >>> Thundering herds of a sort pounding the LRU locks from direct reclaim
> >>> have set off the NMI oopser for users here.
> >> Ditto here.
> > 
> > Opterons?
> 
> It's happened on IA64, too.  Probably on Intel x86-64 as well.

Opterons seem to be particularly prone to lock starvation where a cacheline
gets captured in a single package for ever.

> >> The main reason they end up pounding the LRU locks is the
> >> swappiness heuristic.  They scan too much before deciding
> >> that it would be a good idea to actually swap something
> >> out, and with 32 CPUs doing such scanning simultaneously...
> > 
> > What kernel version?
> 
> Customers are on the 2.6.9 based RHEL4 kernel, but I believe
> we have reproduced the problem on 2.6.18 too during stress
> tests.

The prev_priority fixes were post-2.6.18

> I have no reason to believe we should stick our heads in the
> sand and pretend it no longer exists on 2.6.21.

I have no reason to believe anything.  All I see is handwaviness,
speculation and grand plans to rewrite vast amounts of stuff without even a
testcase to demonstrate that said rewrite improved anything.

None of this is going anywhere, is it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
