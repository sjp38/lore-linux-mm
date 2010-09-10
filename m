Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B2BB96B00A1
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 06:33:37 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8AAXYUH031279
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Sep 2010 19:33:34 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E354445DE4F
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 19:33:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C24B745DE4E
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 19:33:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA3171DB8037
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 19:33:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 445301DB803E
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 19:33:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 05/10] vmscan: Synchrounous lumpy reclaim use lock_page() instead trylock_page()
In-Reply-To: <20100909182649.C94F.A69D9226@jp.fujitsu.com>
References: <20100909092203.GL29263@csn.ul.ie> <20100909182649.C94F.A69D9226@jp.fujitsu.com>
Message-Id: <20100910193307.C97B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Sep 2010 19:33:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Afaik, detailed rule is,
> 
> o kswapd can call lock_page() because they never take page lock outside vmscan

s/lock_page()/lock_page_nosync()/



> o if try_lock() is successed, we can call lock_page_nosync() against its page after unlock.
>   because the task have gurantee of no lock taken.
> o otherwise, direct reclaimer can't call lock_page(). the task may have a lock already.
> 
> I think.
> 
> 
> >  I did not
> > think of an obvious example of when this would happen. Similarly,
> > deadlock situations with mmap_sem shouldn't happen unless multiple page
> > locks are being taken.
> > 
> > (prepares to feel foolish)
> > 
> > What did I miss?
> 
> 
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
