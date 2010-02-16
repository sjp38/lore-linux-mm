Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 828416B0098
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 03:51:14 -0500 (EST)
Date: Tue, 16 Feb 2010 08:50:59 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/12] Export unusable free space index via
	/proc/pagetypeinfo
Message-ID: <20100216085058.GD26086@csn.ul.ie>
References: <20100216152106.72FA.A69D9226@jp.fujitsu.com> <20100216083612.GA26086@csn.ul.ie> <20100216173832.730F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100216173832.730F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 16, 2010 at 05:41:39PM +0900, KOSAKI Motohiro wrote:
> > On Tue, Feb 16, 2010 at 04:03:29PM +0900, KOSAKI Motohiro wrote:
> > > > Unusuable free space index is a measure of external fragmentation that
> > > > takes the allocation size into account. For the most part, the huge page
> > > > size will be the size of interest but not necessarily so it is exported
> > > > on a per-order and per-zone basis via /proc/pagetypeinfo.
> > > 
> > > Hmmm..
> > > /proc/pagetype have a machine unfriendly format. perhaps, some user have own ugly
> > > /proc/pagetype parser. It have a little risk to break userland ABI.
> > > 
> > 
> > It's very low risk. I doubt there are machine parsers of
> > /proc/pagetypeinfo because there are very few machine-orientated actions
> > that can be taken based on the information. It's more informational for
> > a user if they were investigating fragmentation problems.
> > 
> > > I have dumb question. Why can't we use another file?
> > 
> > I could. What do you suggest?
> 
> I agree it's low risk. but personally I hope fragmentation ABI keep very stable because
> I expect some person makes userland compaction daemon. (read fragmentation index
> from /proc and write /proc/compact_memory if necessary).
> then, if possible, I hope fragmentation info have individual /proc file.
> 

I'd be somewhat surprised if there was an active userland compaction daemon
because I'd expect them to be depending on direct compaction.  Userspace
compaction is more likely to be an all-or-nothing affair and confined to
NUMA nodes if they are being used as containers. If a compaction daemon was
to exist, I'd have expected it to be in-kernel because the triggers from
userspace are so coarse.

Still, I can break out the indices into separate files to cover all the
bases.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
