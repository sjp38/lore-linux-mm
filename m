Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F2D496B0083
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 10:56:35 -0400 (EDT)
Date: Mon, 18 Jul 2011 09:56:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Initialise ZLC for first zone
 eligible for zone_reclaim
In-Reply-To: <1310742540-22780-2-git-send-email-mgorman@suse.de>
Message-ID: <alpine.DEB.2.00.1107180951390.30392@router.home>
References: <1310742540-22780-1-git-send-email-mgorman@suse.de> <1310742540-22780-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 15 Jul 2011, Mel Gorman wrote:

> Currently the zonelist cache is setup only after the first zone has
> been considered and zone_reclaim() has been called. The objective was
> to avoid a costly setup but zone_reclaim is itself quite expensive. If
> it is failing regularly such as the first eligible zone having mostly
> mapped pages, the cost in scanning and allocation stalls is far higher
> than the ZLC initialisation step.

Would it not be easier to set zlc_active and allowednodes based on the
zone having an active ZLC at the start of get_pages()?

Buffered_rmqueue is handling the situation of a zone with an ZLC in a
weird way right now since it ignores the (potentially existing) ZLC
for the first pass. zlc_setup() does a lot of things. So that is because
there is a performance benefit?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
