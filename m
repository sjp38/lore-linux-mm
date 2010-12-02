Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 96A348D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 20:28:53 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB21SoM6025763
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Dec 2010 10:28:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 662E945DE55
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:28:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49DBB45DE5C
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:28:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C8F7E38001
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:28:50 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D7C6BE38005
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:28:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
In-Reply-To: <1291249749.12777.86.camel@sli10-conroe>
References: <20101201155854.GA3372@barrios-desktop> <1291249749.12777.86.camel@sli10-conroe>
Message-Id: <20101202101555.157C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu,  2 Dec 2010 10:28:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> > In addtion, new order is always less than old order in that context. 
> > so big order page reclaim makes much safe for low order pages.
> big order page reclaim makes we have more chances to reclaim useful
> pages by lumpy, why it's safe?

Because some crappy driver try high order GFP_ATOMIC allocation and
they often don't have enough failure handling.

Even though they have good allocation failure handling, network packet
loss (wireless drivers are one of most big high order GFP_ATOMIC user) is
usually big impact than page cache drop/re-readings.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
