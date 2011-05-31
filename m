Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7EF6B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 03:14:50 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4696E3EE0BC
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:14:47 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 26E9A45DED1
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:14:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B55E45DECB
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:14:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F39E71DB804A
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:14:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BDD7B1DB8045
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:14:46 +0900 (JST)
Message-ID: <4DE4955E.5010503@jp.fujitsu.com>
Date: Tue, 31 May 2011 16:14:38 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
References: <20110530131300.GQ5044@csn.ul.ie>
In-Reply-To: <20110530131300.GQ5044@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mel@csn.ul.ie
Cc: akpm@linux-foundation.org, urykhy@gmail.com, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

(2011/05/30 22:13), Mel Gorman wrote:
> Asynchronous compaction is used when promoting to huge pages. This is
> all very nice but if there are a number of processes in compacting
> memory, a large number of pages can be isolated. An "asynchronous"
> process can stall for long periods of time as a result with a user
> reporting that firefox can stall for 10s of seconds. This patch aborts
> asynchronous compaction if too many pages are isolated as it's better to
> fail a hugepage promotion than stall a process.
> 
> If accepted, this should also be considered for 2.6.39-stable. It should
> also be considered for 2.6.38-stable but ideally [11bc82d6: mm:
> compaction: Use async migration for __GFP_NO_KSWAPD and enforce no
> writeback] would be applied to 2.6.38 before consideration.
> 
> Reported-and-Tested-by: Ury Stankevich <urykhy@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
