Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAPBZDSe004722
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 25 Nov 2008 20:35:13 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 759D445DE50
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 20:35:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 543D645DE4F
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 20:35:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 37D3E1DB803A
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 20:35:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E53261DB8037
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 20:35:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max pages
In-Reply-To: <20081124145057.4211bd46@bree.surriel.com>
References: <20081124145057.4211bd46@bree.surriel.com>
Message-Id: <20081125203333.26F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 25 Nov 2008 20:35:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> Sometimes the VM spends the first few priority rounds rotating back
> referenced pages and submitting IO.  Once we get to a lower priority,
> sometimes the VM ends up freeing way too many pages.
> 
> The fix is relatively simple: in shrink_zone() we can check how many
> pages we have already freed, direct reclaim tasks break out of the
> scanning loop if they have already freed enough pages and have reached
> a lower priority level.
> 
> However, in order to do this we do need to know how many pages we already
> freed, so move nr_reclaimed into scan_control.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> Kosaki, this should address the zone scanning pressure issue.

hmmmm. I still don't like the behavior when priority==DEF_PRIORITY.
but I also should explain by code and benchmark.

therefore, I'll try to mesure this patch in this week.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
