Subject: Re: [PATCH] 2.6.23-rc1-mm1 - fix missing numa_zonelist_order sysctl
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070802094445.6495e25d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1185994972.5059.91.camel@localhost>
	 <20070802094445.6495e25d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 11:07:38 -0400
Message-Id: <1186067258.5040.33.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-02 at 09:44 +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 01 Aug 2007 15:02:51 -0400
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > [But, maybe reordering the zonelists is not such a good idea
> > when ZONE_MOVABLE is populated?]
> > 
> 
> It's case-by-case I think. In zone order with ZONE_MOVABLE case,
> user's page cache will not use ZONE_NORMAL until ZONE_MOVABLE in all node
> is exhausted. This is an expected behavior, I think.
> 
> I think the real problem is the scheme for "How to set zone movable size to
> appropriate value for the system". This needs more study and documentation.
> (but maybe depends on system configuration to some extent.)

Yes.  Having thought about it a bit more, maybe zone order IS what we
want if we desire the remainder of the zone from which is was taken
[ZONE_MOVABLE-1] to be reserved for non-movable kernel use as long as
possible--similar to the dma zone.  I had made the non-movable zone very
large for testing, so that I could create a segment that used all of the
movable zones on all the nodes and then dip into the non-movable/normal
zone.  If I used a more reasonable [much smaller] amount of kernelcore,
the interleave would have worked as "expected".  

Of course, I don't have any idea of what is a "reasonable amount".
Guess I could look at non-movable zone memory usage in a system at
typical or peak load to get an idea.  Anyone have any data in this
regard?

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
