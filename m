Date: Fri, 2 Mar 2007 13:37:32 -0800
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302213732.GK10643@holomorphy.com>
References: <20070301101249.GA29351@skynet.ie> <20070302015235.GG10643@holomorphy.com> <Pine.LNX.4.64.0703021018070.32022@skynet.skynet.ie> <45E8516B.5090203@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45E8516B.5090203@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Bill Irwin <bill.irwin@oracle.com>, akpm@linux-foundation.org, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, arjan@infradead.org, torvalds@osdl.org, mbligh@mbligh.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

At some point in the past, Mel Gorman wrote:
>> I can't think of a workload that totally makes a mess out of list-based. 
>> However, list-based makes no guarantees on availability. If a system 
>> administrator knows they need between 10,000 and 100,000 huge pages and 
>> doesn't want to waste memory pinning too many huge pages at boot-time, 
>> the zone-based mechanism would be what he wanted.

On Fri, Mar 02, 2007 at 10:31:39AM -0600, Joel Schopp wrote:
> From our testing with earlier versions of list based for memory hot-unplug 
> on pSeries machines we were able to hot-unplug huge amounts of memory after 
> running the nastiest workloads we could find for over a week.  Without the 
> patches we were unable to hot-unplug anything within minutes of running the 
> same workloads.
> If something works for 99.999% of people (list based) and there is an easy 
> way to configure it for the other 0.001% of the people ("zone" based) I 
> call that a great solution.  I really don't understand what the resistance 
> is to these patches.

Sorry if I was unclear; I was anticipating others' objections and
offering to assist in responding to them. I myself have no concerns
about the above strategy, apart from generally wanting to recover the
list-based patch's hugepage availability without demanding it as a
merging criterion.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
