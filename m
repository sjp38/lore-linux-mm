Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9G87kCl028009
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Oct 2008 17:07:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B899D2AC026
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 17:07:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C37512C044
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 17:07:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BCEF1DB803B
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 17:07:46 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 12AFB1DB803E
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 17:07:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
In-Reply-To: <20081016153750.4E22.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081015233126.27885bb9.akpm@linux-foundation.org> <20081016153750.4E22.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081016170400.4E27.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Oct 2008 17:07:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

> > > mmotm mode,
> > > 
> > > 1, shrink_inactive_list() free copy's page.
> > > 2. end!
> > 
> > OK.  But my concern is that perhaps the above latency improvement was
> > caused by one of the many other MM patches in mmotm.
> > 
> > Reverting mm-more-likely-reclaim-madv_sequential-mappings.patch from
> > mmotm and rerunning the tests would be the way to determine this. 
> > (hint :) - thanks).
> 
> fair enough.
> OK, please wait half hour.

I mesured 2.6.27+sequential-patch.

                                   (NEW)
                         2.6.27    2.6.27+patch   mmotm-1010
   ==============================================================
   mm_sync_madv_cp       6:14      6:03           6:02         (min:sec)
   dbench throughput     12.1507   13.915         14.6273      (MB/s)
   dbench latency        33046     22062          21779        (ms)


Hm, I think other patches influence isn't so much.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
