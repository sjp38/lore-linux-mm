Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5EDC06B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 09:30:49 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4893982C6B6
	for <linux-mm@kvack.org>; Thu, 21 May 2009 09:44:45 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4ONk+KU9Gr3K for <linux-mm@kvack.org>;
	Thu, 21 May 2009 09:44:45 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9502482C735
	for <linux-mm@kvack.org>; Thu, 21 May 2009 09:44:40 -0400 (EDT)
Date: Thu, 21 May 2009 09:31:08 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <20090521090549.63B5.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0905210924520.31888@qirst.com>
References: <20090519102003.4EAB.A69D9226@jp.fujitsu.com> <20090520140045.GA29447@sgi.com> <20090521090549.63B5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Robin Holt <holt@sgi.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 21 May 2009, KOSAKI Motohiro wrote:

> I can't catch up your message. Can you post your patch?
> Can you explain your sanity check?
>
> Now, I decide to remove "nr_online_nodes >= 4" condition.
> Apache regression is really non-sense.

Not sure what that means? Apache regresses with zone reclaim? My
measurements when we introduced zone reclaim showed just the opposite
because Apache would get node local memory and thus run faster. You can
screw this up of course if you load the system so high that the apache
processes are tossed around by the scheduler. Then the node local
allocation may be worse than round robin because all the pages allocated
by a process are now on one node if the scheduler moves the
process to a remote node then all accesses are penalized.

> > Even with 128 nodes and 256 cpus, I _NEVER_ see the
> > system swapping out before allocating off node so I can certainly not
> > reproduce the situation you are seeing.
>
> hmhm. but I don't think we can assume hpc workload.

System swapping due to zone reclaim? zone reclaim only reclaims unmapped
pages so it will not swap. Maybe some bug crept in in the recent changes?
Or you overrode the defaults for zone reclaim?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
