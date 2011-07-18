Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AE32D6B004A
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 17:54:14 -0400 (EDT)
Date: Mon, 18 Jul 2011 16:54:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Initialise ZLC for first zone
 eligible for zone_reclaim
In-Reply-To: <20110718211325.GC5349@suse.de>
Message-ID: <alpine.DEB.2.00.1107181651000.31576@router.home>
References: <1310742540-22780-1-git-send-email-mgorman@suse.de> <1310742540-22780-2-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1107180951390.30392@router.home> <20110718160552.GB5349@suse.de> <alpine.DEB.2.00.1107181208050.31576@router.home>
 <20110718211325.GC5349@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 18 Jul 2011, Mel Gorman wrote:

> > We may be able to simplify the function by:
> >
> > 1.  Checking for the special case that the first zone is ok and that we do
> > not want to call zlc_setup before we get to the loop.
> >
> > 2. Do the zlc_setup() before the loop.
> >
> > 3. Remove the zlc_setup() code as you did from the loop as well as the
> > checks for zlc_active. zlc_active becomes not necessary since a zlc
> > is always available when we go through the loop.
> >
>
> That initial test will involve duplication of things like the cpuset and
> no watermarks check just to place the zlc_setup() in a different place.
> I might be missing your point but it seems like the gain would be
> marginal. Fancy posting a patch?

Looked at it for some time. Would have to create a new function for the
watermark checks, the call to buffer_rmqueue and the marking of a zone as
full. After that the goto mess could be unraveled. But I am out of time
for today.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
