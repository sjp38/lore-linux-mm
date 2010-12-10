Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A8BB66B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 20:24:52 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBA1OmV4005714
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Dec 2010 10:24:48 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7504C45DE5F
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:24:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D46B45DE59
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:24:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49A57E38002
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:24:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 114781DB8047
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:24:48 +0900 (JST)
Date: Fri, 10 Dec 2010 10:19:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/6] mm: kswapd: Reset kswapd_max_order and
 classzone_idx after reading
Message-Id: <20101210101907.61f3019b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1291893500-12342-5-git-send-email-mel@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
	<1291893500-12342-5-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu,  9 Dec 2010 11:18:18 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> When kswapd wakes up, it reads its order and classzone from pgdat and
> calls balance_pgdat. While its awake, it potentially reclaimes at a high
> order and a low classzone index. This might have been a once-off that
> was not required by subsequent callers. However, because the pgdat
> values were not reset, they remain artifically high while
> balance_pgdat() is running and potentially kswapd enters a second
> unnecessary reclaim cycle. Reset the pgdat order and classzone index
> after reading.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
