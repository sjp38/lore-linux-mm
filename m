Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 37A5A6B00A7
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:09:34 -0500 (EST)
Received: from fgwmail7.fujitsu.co.jp (fgwmail7.fujitsu.co.jp [192.51.44.37])
	by fgwmail8.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB209Uxw012453
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Dec 2010 09:09:30 +0900
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB209RwA028514
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Dec 2010 09:09:27 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A57FF45DE67
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 09:09:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E56345DE61
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 09:09:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 831A71DB803A
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 09:09:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FB7E1DB8038
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 09:09:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
In-Reply-To: <20101201155854.GA3372@barrios-desktop>
References: <20101201132730.ABC2.A69D9226@jp.fujitsu.com> <20101201155854.GA3372@barrios-desktop>
Message-Id: <20101202090952.1567.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Dec 2010 09:09:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> It might work well. but I don't like such a coding that kswapd_try_to_sleep's
> eturn value is order. It doesn't look good to me and even no comment. Hmm..
> 
> How about this?
> If you want it, feel free to use it.
> If you insist on your coding style, I don't have any objection.
> Then add My Reviewed-by.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

I'm ok this.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
