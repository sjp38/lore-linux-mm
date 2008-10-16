Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9G6cTmC022763
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Oct 2008 15:38:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C12532AC028
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:38:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 91F2E12C044
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:38:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 687AF1DB803B
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:38:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CC021DB8040
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:38:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
In-Reply-To: <20081015233126.27885bb9.akpm@linux-foundation.org>
References: <20081016151030.5832.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081015233126.27885bb9.akpm@linux-foundation.org>
Message-Id: <20081016153750.4E22.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Oct 2008 15:38:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

> > mmotm mode,
> > 
> > 1, shrink_inactive_list() free copy's page.
> > 2. end!
> 
> OK.  But my concern is that perhaps the above latency improvement was
> caused by one of the many other MM patches in mmotm.
> 
> Reverting mm-more-likely-reclaim-madv_sequential-mappings.patch from
> mmotm and rerunning the tests would be the way to determine this. 
> (hint :) - thanks).

fair enough.
OK, please wait half hour.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
