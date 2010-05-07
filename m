Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5E1CF6200B2
	for <linux-mm@kvack.org>; Fri,  7 May 2010 04:17:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o478HF8I021640
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 May 2010 17:17:15 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C9D0145DE51
	for <linux-mm@kvack.org>; Fri,  7 May 2010 17:17:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A7C7645DD6E
	for <linux-mm@kvack.org>; Fri,  7 May 2010 17:17:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FC3D1DB803F
	for <linux-mm@kvack.org>; Fri,  7 May 2010 17:17:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 48FF01DB803A
	for <linux-mm@kvack.org>; Fri,  7 May 2010 17:17:14 +0900 (JST)
Date: Fri, 7 May 2010 17:13:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] Fix migration races in rmap_walk() V7
Message-Id: <20100507171310.4c15c4cc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1273188053-26029-1-git-send-email-mel@csn.ul.ie>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri,  7 May 2010 00:20:51 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> No major change since V6, just looks nicer.
> 

seems to work well in my test.
I think there is no unknown pitfalls. I'm glad if you double check my
concern for patch [1/2].

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
