Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id F08506B00A2
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 03:04:58 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0E98B3EE0B6
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 17:04:56 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E374045DF4B
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 17:04:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C820045DF47
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 17:04:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA46EE08003
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 17:04:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 66F811DB8040
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 17:04:55 +0900 (JST)
Date: Wed, 23 Nov 2011 17:03:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: add task name to warn_scan_unevictable()
 messages
Message-Id: <20111123170319.cc668d61.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322027721-23677-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
References: <1322027721-23677-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Andrew Morton (commit_signer:71/87=82%)" <akpm@linux-foundation.org>, "Mel Gorman (commit_signer:39/87=45%)" <mgorman@suse.de>, "Minchan Kim (commit_signer:32/87=37%)" <minchan.kim@gmail.com>, "Johannes Weiner (commit_signer:21/87=24%)" <jweiner@redhat.com>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

On Wed, 23 Nov 2011 00:55:20 -0500
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> If we need to know a usecase, caller program name is critical important.
> Show it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
seems nice.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
