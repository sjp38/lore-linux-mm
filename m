Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C600B6B004D
	for <linux-mm@kvack.org>; Sun, 24 May 2009 09:43:51 -0400 (EDT)
Date: Sun, 24 May 2009 22:44:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <alpine.DEB.1.10.0905210924520.31888@qirst.com>
References: <20090521090549.63B5.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905210924520.31888@qirst.com>
Message-Id: <20090524223857.0852.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Robin Holt <holt@sgi.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


sorry I missed this mail

> > > Even with 128 nodes and 256 cpus, I _NEVER_ see the
> > > system swapping out before allocating off node so I can certainly not
> > > reproduce the situation you are seeing.
> >
> > hmhm. but I don't think we can assume hpc workload.
> 
> System swapping due to zone reclaim? zone reclaim only reclaims unmapped
> pages so it will not swap. Maybe some bug crept in in the recent changes?
> Or you overrode the defaults for zone reclaim?

I guess he use zone_reclaim_mode=7 or similar.

However, I have to explain recent zone reclaim change. current zone reclaim is

 1. zone reclaim can make high order reclaim (by hanns)
 2. determine file-backed page by get_scan_ratio

it mean, high order allocation makes lumpy zone reclaim. and shrink_inactive_list()
don't care may_swap. then, zone_reclaim_mode=1 can makes swap-out if your
driver makes high order allocation request.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
