Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id F049F6B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 12:59:12 -0500 (EST)
Date: Fri, 9 Nov 2012 15:58:44 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v11 3/7] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20121109175844.GD4308@optiplex.redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
 <4ea10ef1eb1544e12524c8ca7df20cf621395463.1352256087.git.aquini@redhat.com>
 <20121109121133.GP3886@csn.ul.ie>
 <20121109145321.GB4308@optiplex.redhat.com>
 <20121109162327.GT3886@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121109162327.GT3886@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Nov 09, 2012 at 04:23:27PM +0000, Mel Gorman wrote:
> On Fri, Nov 09, 2012 at 12:53:22PM -0200, Rafael Aquini wrote:
> > > <SNIP>
> > > If you get the barrier issue sorted out then feel free to add
> > > 
> > > Acked-by: Mel Gorman <mel@csn.ul.ie>
> > > 
> > 
> > I believe we can drop the barriers stuff, as the locking scheme is now provinding
> > enough protection against collisions between isolation page scanning and
> > balloon_leak() page release (the major concern that has lead to the barriers
> > originally)
> > 
> > I'll refactor this patch with no barriers and ensure a better commentary on the
> > aforementioned locking scheme and resubmit, if it's OK to everyone
> > 
> 
> Sounds good to me. When they are dropped again feel free to stick my ack
> on for the compaction and migration parts. The virtio aspects are up to
> someone else :)
> 

Andrew,

If we get no further objections raised on dropping those barriers, would you
like me to resubmit the whole series rebased on the latest -next, 
or just this (new) refactored patch?

-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
