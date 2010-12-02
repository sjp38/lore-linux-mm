Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 60E488D0002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:29:40 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB20TaLL013953
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Dec 2010 09:29:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8759145DE5A
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 09:29:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DBEE45DE58
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 09:29:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AF7BE38006
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 09:29:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 269E8E38003
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 09:29:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
In-Reply-To: <20101202090952.1567.A69D9226@jp.fujitsu.com>
References: <20101201155854.GA3372@barrios-desktop> <20101202090952.1567.A69D9226@jp.fujitsu.com>
Message-Id: <20101202092921.1570.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Dec 2010 09:29:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> > It might work well. but I don't like such a coding that kswapd_try_to_sleep's
> > eturn value is order. It doesn't look good to me and even no comment. Hmm..
> > 
> > How about this?
> > If you want it, feel free to use it.
> > If you insist on your coding style, I don't have any objection.
> > Then add My Reviewed-by.
> > 
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> 
> I'm ok this.
> 
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> 
> Thanks.
> 

Please consider rensend a patch with full patch description. Of cource,
you need to rebase this on top Mel's patch.

Plus, please don't remove Shaohua's reported-by tag. It's important line 
than my code. Please respect good bug finder.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
