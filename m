Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 22D846B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 04:19:53 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DB5963EE0BC
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:19:48 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C3BBE45DE83
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:19:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A6F5445DE9F
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:19:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B2C91DB802C
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:19:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 57BED1DB803A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 17:19:48 +0900 (JST)
Message-ID: <4DF1D396.5000404@jp.fujitsu.com>
Date: Fri, 10 Jun 2011 17:19:34 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 01/10] compaction: trivial clean up acct_isolated
References: <cover.1307455422.git.minchan.kim@gmail.com> <71a79768ff8ef356db09493dbb5d6c390e176e0d.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <71a79768ff8ef356db09493dbb5d6c390e176e0d.1307455422.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com

(2011/06/07 23:38), Minchan Kim wrote:
> acct_isolated of compaction uses page_lru_base_type which returns only
> base type of LRU list so it never returns LRU_ACTIVE_ANON or LRU_ACTIVE_FILE.
> In addtion, cc->nr_[anon|file] is used in only acct_isolated so it doesn't have
> fields in conpact_control.
> This patch removes fields from compact_control and makes clear function of
> acct_issolated which counts the number of anon|file pages isolated.
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
