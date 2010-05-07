Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 08C4B6B0239
	for <linux-mm@kvack.org>; Fri,  7 May 2010 01:53:46 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o475riEm023804
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 May 2010 14:53:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D971845DE51
	for <linux-mm@kvack.org>; Fri,  7 May 2010 14:53:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B5CC145DE4F
	for <linux-mm@kvack.org>; Fri,  7 May 2010 14:53:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 984601DB8015
	for <linux-mm@kvack.org>; Fri,  7 May 2010 14:53:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 520251DB8014
	for <linux-mm@kvack.org>; Fri,  7 May 2010 14:53:43 +0900 (JST)
Date: Fri, 7 May 2010 14:49:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-Id: <20100507144937.2266df7d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100507085219.5821f721.kamezawa.hiroyu@jp.fujitsu.com>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie>
	<1273065281-13334-2-git-send-email-mel@csn.ul.ie>
	<20100506163837.bf6587ef.kamezawa.hiroyu@jp.fujitsu.com>
	<20100506094621.GZ20979@csn.ul.ie>
	<20100507085219.5821f721.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 May 2010 08:52:19 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 6 May 2010 10:46:21 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:

> > 5. It added a field to mm_struct. It's the smallest of concerns though.
> > 
> > Do you think it's a better approach and should be revisited?
> > 
> > 
> 
> If everyone think seqlock is simple, I think it should be. But it seems you all are
> going ahead with anon_vma->lock approach. 
> (Basically, it's ok to me if it works. We may be able to make it better in later.)
> 
> I'll check your V7.
> 
> Thank you for answering.

plz forget about seq_counter. we may have to add "retry" path for avoiding
dead lock. If so, using anon_vma->lock in proper manner seems sane.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
