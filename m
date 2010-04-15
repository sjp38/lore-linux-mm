Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 875476B0201
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 04:17:45 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F8HgPF014385
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 17:17:42 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BC8C645DE58
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:17:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D8FF45DE56
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:17:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C4B1E1DB805E
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:17:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 63A4E1DB8038
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:17:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if current is kswapd
In-Reply-To: <64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org>
References: <20100415131106.D174.A69D9226@jp.fujitsu.com> <64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org>
Message-Id: <20100415171142.D192.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 17:17:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Suleiman Souhlal <ssouhlal@freebsd.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, suleiman@google.com
List-ID: <linux-mm.kvack.org>

> 
> On Apr 14, 2010, at 9:11 PM, KOSAKI Motohiro wrote:
> 
> > Now, vmscan pageout() is one of IO throuput degression source.
> > Some IO workload makes very much order-0 allocation and reclaim
> > and pageout's 4K IOs are making annoying lots seeks.
> >
> > At least, kswapd can avoid such pageout() because kswapd don't
> > need to consider OOM-Killer situation. that's no risk.
> >
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> What's your opinion on trying to cluster the writes done by pageout,  
> instead of not doing any paging out in kswapd?
> Something along these lines:

Interesting. 
So, I'd like to review your patch carefully. can you please give me one
day? :)


> 
>      Cluster writes to disk due to memory pressure.
> 
>      Write out logically adjacent pages to the one we're paging out
>      so that we may get better IOs in these situations:
>      These pages are likely to be contiguous on disk to the one we're
>      writing out, so they should get merged into a single disk IO.
> 
>      Signed-off-by: Suleiman Souhlal <suleiman@google.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
