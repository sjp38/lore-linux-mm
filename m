Date: Tue, 8 Apr 2003 18:19:11 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: meminfo documentation
Message-ID: <20030409011911.GA21761@holomorphy.com>
References: <3E936E2A.4080400@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3E936E2A.4080400@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 08, 2003 at 05:49:46PM -0700, Dave Hansen wrote:
> ReverseMaps:  number of rmap pte chains

It's not about the number of pte_chains. There are 3 ways to think of it:

(1) number of reverse mappings performed.
(2) total number of pte's in pte_chains
(3) total faulted-in memory-backed virtualspace

pte_chain objects may partially utilize slabs, and a given chain of
pte_chain objects may be partially utilized within a given chain,
as there are 7 pointers or so in an object, and you have to fill a
chain with a precise number of pte's to fully utilize the objects.

So, there are two levels at which internal fragmentation can happen.
This measures the one _not_ detectable from /proc/slabinfo, which is
the internal fragmentation at the pte-filling-object-level.

The number these days is not particularly useful for the measurement
of internal fragmentation due to the PG_direct changes, but could be
fixed up to measure it again. This stat is slated to be removed soon
because it's measurably expensive to collect (which is good; any stat
with that kind of performance impact should either die or be config'd).

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
