Date: Fri, 2 Mar 2007 12:59:33 -0800
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302205933.GI10643@holomorphy.com>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <45E842F6.5010105@redhat.com> <20070302085838.bcf9099e.akpm@linux-foundation.org> <Pine.LNX.4.64.0703020919350.16719@schroedinger.engr.sgi.com> <20070302093501.34c6ef2a.akpm@linux-foundation.org> <45E8624E.2080001@redhat.com> <20070302100619.cec06d6a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070302100619.cec06d6a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@engr.sgi.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 02 Mar 2007 12:43:42 -0500 Rik van Riel <riel@redhat.com> wrote:
>> I can't share all the details, since a lot of the problems are customer
>> workloads.
>> One particular case is a 32GB system with a database that takes most
>> of memory.  The amount of actually freeable page cache memory is in
>> the hundreds of MB.

On Fri, Mar 02, 2007 at 10:06:19AM -0800, Andrew Morton wrote:
> Where's the rest of the memory? tmpfs?  mlocked?  hugetlb?

I know of one sounding similar to this where unreclaimable pages are
pinned by refcounts held by bio's spread across about 850 spindles.
It's mostly read traffic. Several different tunables could be used
to work around it, nr_requests in particular, but also clamping down
on dirty limits to preposterously low levels and setting preposterously
large values of min_free_kbytes. Their kernel is, of course,
substantially downrev (2.6.9-based IIRC), so douse things heavily with
grains of salt.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
