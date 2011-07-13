Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E45D46B007E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 06:40:34 -0400 (EDT)
Date: Wed, 13 Jul 2011 11:40:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/3] mm: vmscan: Do use use PF_SWAPWRITE from zone_reclaim
Message-ID: <20110713104025.GE7529@suse.de>
References: <1310389274-13995-1-git-send-email-mgorman@suse.de>
 <1310389274-13995-2-git-send-email-mgorman@suse.de>
 <CAEwNFnATXiQsmbfuvZNEtcpcVZkyZKRFB1SKbkEREaCW4S-aUg@mail.gmail.com>
 <4E1C1684.4090706@jp.fujitsu.com>
 <CAEwNFnAprEuZJucDSMgnUHGePyxgyRqNCWOsG0-K2nTjmKcUug@mail.gmail.com>
 <alpine.DEB.2.00.1107121042240.2530@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107121042240.2530@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 12, 2011 at 10:43:47AM -0500, Christoph Lameter wrote:
> On Tue, 12 Jul 2011, Minchan Kim wrote:
> 
> > If I am not against this patch, at least, we need agreement of
> > Christoph and others and if we agree this change, we changes vm.txt,
> > too.
> 
> I think PF_SWAPWRITE should only be set if may_write was set earlier in
> __zone_reclaim. If zone reclaim is not configured to do writeback then it
> makes no sense to set the bit.
> 

That would effectively make the patch a no-op as the check for
PF_SWAPWRITE only happens if may_write is set. The point of the patch is
that zone reclaim differs from direct reclaim in that zone reclaim
obeys congestion where as zone reclaim does not. If you're saying that
this is the way it's meant to be, then fine, I'll drop the patch. While
I think it's a bad idea, I also didn't specifically test for problems
related to it and I think the other two patches in the series are more
important.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
