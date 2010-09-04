Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9BF566B0047
	for <linux-mm@kvack.org>; Sat,  4 Sep 2010 04:15:17 -0400 (EDT)
Date: Sat, 4 Sep 2010 18:14:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-ID: <20100904081414.GF705@dastard>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie>
 <1283504926-2120-4-git-send-email-mel@csn.ul.ie>
 <20100903160026.564fdcc9.akpm@linux-foundation.org>
 <20100904022545.GD705@dastard>
 <20100903202101.f937b0bb.akpm@linux-foundation.org>
 <20100904075840.GE705@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100904075840.GE705@dastard>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, Sep 04, 2010 at 05:58:40PM +1000, Dave Chinner wrote:
> On Fri, Sep 03, 2010 at 08:21:01PM -0700, Andrew Morton wrote:
> > On Sat, 4 Sep 2010 12:25:45 +1000 Dave Chinner <david@fromorbit.com> wrote:
> > 
> > > Still, given the improvements in performance from this patchset,
> > > I'd say inclusion is a no-braniner....
> > 
> > OK, thanks.
> > 
> > It'd be interesting to check the IPI frequency with and without -
> > /proc/interrupts "CAL" field.  Presumably it went down a lot.
> 
> Maybe I suspected you would ask for this. I happened to dump
> /proc/interrupts after the livelock run finished, so you're in
> luck :)
....
> 
> livelock:  59458 58367 58559 59493 59614 57970 59060 58207
> 
> So the livelock case tends to indicate roughly 40,000 more IPI
> interrupts per CPU occurred.  The livelock occurred for close to 5
> minutes, so that's roughly 130 IPIs per second per CPU....

And just to confuse the issue further, I just had a livelock on a
vanilla kernel that did *not* cause the CAL counts to increase.
Hence it appears that the IPI storms are not the cause of the
livelocks D?'m triggering....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
