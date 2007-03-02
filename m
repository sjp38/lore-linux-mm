Date: Fri, 2 Mar 2007 11:31:16 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <45E86BA0.50508@redhat.com>
Message-ID: <Pine.LNX.4.64.0703021126470.17883@schroedinger.engr.sgi.com>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org>
 <45E842F6.5010105@redhat.com> <20070302085838.bcf9099e.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703020919350.16719@schroedinger.engr.sgi.com>
 <20070302093501.34c6ef2a.akpm@linux-foundation.org> <45E8624E.2080001@redhat.com>
 <20070302100619.cec06d6a.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703021012170.17676@schroedinger.engr.sgi.com>
 <45E86BA0.50508@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007, Rik van Riel wrote:

> I would like to see separate pageout selection queues
> for anonymous/tmpfs and page cache backed pages.  That
> way we can simply scan only that what we want to scan.
> 
> There are several ways available to balance pressure
> between both sets of lists.
> 
> Splitting them out will also make it possible to do
> proper use-once replacement for the page cache pages.
> Ie. leaving the really active page cache pages on the
> page cache active list, instead of deactivating them
> because they're lower priority than anonymous pages.

Well I would expect this to have marginal improvements and delay the 
inevitable for awhile until we have even bigger memory. If the app uses 
mmapped data areas then the problem is still there. And such tinkering 
does not solve the issue of large scale I/O requiring the handling of 
gazillions of page structs. I do not think that there is a way around 
somehow handling larger chunks of memory in an easier way. We already do 
handle larger page sizes for some limited purposes and with huge pages we 
already have a larger page size. Mel's defrag/anti-frag patches are 
necessary to allow us to deal with the resulting fragmentation problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
