Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B12096B01E3
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 04:26:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F8QXcn014556
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 17:26:33 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C9AE45DE4F
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:26:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B52645DE4D
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:26:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 19CD5E08002
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:26:33 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB74D1DB8040
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 17:26:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if current is kswapd
In-Reply-To: <20100415171142.D192.A69D9226@jp.fujitsu.com>
References: <64BE60A8-EEF9-4AC6-AF0A-0ED3CB544726@freebsd.org> <20100415171142.D192.A69D9226@jp.fujitsu.com>
Message-Id: <20100415172215.D19B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 17:26:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Suleiman Souhlal <ssouhlal@freebsd.org>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, suleiman@google.com
List-ID: <linux-mm.kvack.org>

Cc to Johannes

> > 
> > On Apr 14, 2010, at 9:11 PM, KOSAKI Motohiro wrote:
> > 
> > > Now, vmscan pageout() is one of IO throuput degression source.
> > > Some IO workload makes very much order-0 allocation and reclaim
> > > and pageout's 4K IOs are making annoying lots seeks.
> > >
> > > At least, kswapd can avoid such pageout() because kswapd don't
> > > need to consider OOM-Killer situation. that's no risk.
> > >
> > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 
> > What's your opinion on trying to cluster the writes done by pageout,  
> > instead of not doing any paging out in kswapd?
> > Something along these lines:
> 
> Interesting. 
> So, I'd like to review your patch carefully. can you please give me one
> day? :)

Hannes, if my remember is correct, you tried similar swap-cluster IO
long time ago. now I can't remember why we didn't merged such patch.
Do you remember anything?


> 
> 
> > 
> >      Cluster writes to disk due to memory pressure.
> > 
> >      Write out logically adjacent pages to the one we're paging out
> >      so that we may get better IOs in these situations:
> >      These pages are likely to be contiguous on disk to the one we're
> >      writing out, so they should get merged into a single disk IO.
> > 
> >      Signed-off-by: Suleiman Souhlal <suleiman@google.com>
> 
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
