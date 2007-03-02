Date: Fri, 2 Mar 2007 08:58:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070302085838.bcf9099e.akpm@linux-foundation.org>
In-Reply-To: <45E842F6.5010105@redhat.com>
References: <20070301101249.GA29351@skynet.ie>
	<20070301160915.6da876c5.akpm@linux-foundation.org>
	<45E842F6.5010105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 02 Mar 2007 10:29:58 -0500 Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> 
> > And I'd judge that per-container RSS limits are of considerably more value
> > than antifrag (in fact per-container RSS might be a superset of antifrag,
> > in the sense that per-container RSS and containers could be abused to fix
> > the i-cant-get-any-hugepages problem, dunno).
> 
> The RSS bits really worry me, since it looks like they could
> exacerbate the scalability problems that we are already running
> into on very large memory systems.

Using a zone-per-container or N-64MB-zones-per-container should actually
move us in the direction of *fixing* any such problems.  Because, to a
first-order, the scanning of such a zone has the same behaviour as a 64MB
machine.

(We'd run into a few other problems, some related to the globalness of the
dirty-memory management, but that's fixable).

> Linux is *not* happy on 256GB systems.  Even on some 32GB systems
> the swappiness setting *needs* to be tweaked before Linux will even
> run in a reasonable way.

Please send testcases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
