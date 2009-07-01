Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 03A136B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 00:29:59 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n614UsoL029468
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Jul 2009 13:30:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EE7D45DE55
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:30:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A42E45DE52
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:30:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C62A8E08007
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:30:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5283D1DB8040
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 13:30:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Found the commit that causes the OOMs
In-Reply-To: <20090701042554.GA14344@localhost>
References: <20090701131734.85D9.A69D9226@jp.fujitsu.com> <20090701042554.GA14344@localhost>
Message-Id: <20090701132757.85DC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Jul 2009 13:30:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

> > > The question is: Why kswapd reclaims are absent here?
> > 
> > if direct reclaim isolate all pages, kswapd can't reclaim any pages.
> 
> OOM will occur in that condition. What happened before that time?

maybe yes, maybe no.
At first test, the system still have droppable file cache. if direct reclaim luckly take it,
the benchmark become successful end, I think.

Thanks.

> 
> > I believe Rik's idea solve this problem.
> 
> Me too :)
> 
> Thanks,
> Fengguang
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
