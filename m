Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B744C6B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 20:23:47 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBA1Ni7M016231
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Dec 2010 10:23:44 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 378C645DD74
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:23:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DD7545DE67
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:23:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 062381DB803F
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:23:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF1361DB803A
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:23:43 +0900 (JST)
Date: Fri, 10 Dec 2010 10:18:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/6] mm: kswapd: Use the order that kswapd was
 reclaiming at for sleeping_prematurely()
Message-Id: <20101210101802.81b04765.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1291893500-12342-4-git-send-email-mel@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
	<1291893500-12342-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu,  9 Dec 2010 11:18:17 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> Before kswapd goes to sleep, it uses sleeping_prematurely() to check if
> there was a race pushing a zone below its watermark. If the race
> happened, it stays awake. However, balance_pgdat() can decide to reclaim
> at a lower order if it decides that high-order reclaim is not working as
> expected. This information is not passed back to sleeping_prematurely().
> The impact is that kswapd remains awake reclaiming pages long after it
> should have gone to sleep. This patch passes the adjusted order to
> sleeping_prematurely and uses the same logic as balance_pgdat to decide
> if it's ok to go to sleep.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
