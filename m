Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BD8F66B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 04:16:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAI9GM5c006646
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Nov 2010 18:16:23 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 926EE45DE5D
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 18:16:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DD7E45DE4E
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 18:16:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4861BE08002
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 18:16:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 049041DB8038
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 18:16:22 +0900 (JST)
Date: Thu, 18 Nov 2010 18:10:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/8] mm: compaction: Use the LRU to get a hint on where
 compaction should start
Message-Id: <20101118181048.7bdfbb38.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1290010969-26721-8-git-send-email-mel@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
	<1290010969-26721-8-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010 16:22:48 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> The end of the LRU stores the oldest known page. Compaction on the other
> hand always starts scanning from the start of the zone. This patch uses
> the LRU to hint to compaction where it should start scanning from. This
> means that compaction will at least start with some old pages reducing
> the impact on running processes and reducing the amount of scanning. The
> check it makes is racy as the LRU lock is not taken but it should be
> harmless as we are not manipulating the lists without the lock.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Hmm, does this patch make a noticable difference ?
Isn't it better to start scan from the biggest free chunk in a zone ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
