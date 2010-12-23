Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9E98D6B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 19:05:34 -0500 (EST)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id oBNMIj08003708
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 14:18:50 -0800
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by kpbe12.cbf.corp.google.com with ESMTP id oBNMIhiP003370
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 14:18:43 -0800
Received: by pzk27 with SMTP id 27so1574348pzk.0
        for <linux-mm@kvack.org>; Thu, 23 Dec 2010 14:18:42 -0800 (PST)
Date: Thu, 23 Dec 2010 14:18:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
In-Reply-To: <20101129155801.GG13268@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1012231413560.2116@chino.kir.corp.google.com>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie> <1288169256-7174-2-git-send-email-mel@csn.ul.ie> <20101126160619.GP22651@bombadil.infradead.org> <20101129095618.GB13268@csn.ul.ie> <20101129131626.GF15818@bombadil.infradead.org>
 <20101129150824.GF13268@csn.ul.ie> <20101129152230.GH15818@bombadil.infradead.org> <20101129155801.GG13268@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Kyle McMartin <kyle@mcmartin.ca>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 2010, Mel Gorman wrote:

> Andrew, this patch was a performance fix but is a report saying that it
> fixes a functional regression in Fedora enough to push a patch torwards
> stable even though an explanation as to *why* it fixes the problem is missing?
> 

We had to pull aa454840 "mm: page allocator: calculate a better estimate 
of NR_FREE_PAGES when memory is low and kswapd is awake" from 2.6.36 
internally because tests showed that it would cause the machine to stall 
as the result of heavy kswapd activity.  I merged it back with this fix as 
it is pending in the -mm tree and it solves the issue we were seeing, so I 
definitely think this should be pushed to -stable (and I would seriously 
consider it for 2.6.37 inclusion even at this late date).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
