Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 69DB16B01F0
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 07:26:13 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3FBQAa4011794
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 20:26:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 151DF45DE4F
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 20:26:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E0C7245DE56
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 20:26:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA6D51DB8042
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 20:26:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E5B71DB8038
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 20:26:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmscan: delegate pageout io to flusher thread if current is kswapd
In-Reply-To: <20100415103109.GC10966@csn.ul.ie>
References: <20100415131106.D174.A69D9226@jp.fujitsu.com> <20100415103109.GC10966@csn.ul.ie>
Message-Id: <20100415195227.D1B0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 20:26:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Thu, Apr 15, 2010 at 01:11:37PM +0900, KOSAKI Motohiro wrote:
> > Now, vmscan pageout() is one of IO throuput degression source.
> > Some IO workload makes very much order-0 allocation and reclaim
> > and pageout's 4K IOs are making annoying lots seeks.
> > 
> > At least, kswapd can avoid such pageout() because kswapd don't
> > need to consider OOM-Killer situation. that's no risk.
> > 
> 
> Well, there is some risk here. Direct reclaimers may not be cleaning
> more pages than it had to previously except it splices subsystems
> together increasing stack usage and causing further problems.
> 
> It might not cause OOM-killer issues but it could increase the time
> dirty pages spend on the LRU.
> 
> Am I missing something?

No. you are right. I fully agree your previous mail. so, I need to cool down a bit ;)







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
