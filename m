Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 731BE6200AA
	for <linux-mm@kvack.org>; Thu,  6 May 2010 20:12:59 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o470Cs2d017858
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 May 2010 09:12:54 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 05D8A45DE63
	for <linux-mm@kvack.org>; Fri,  7 May 2010 09:12:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA09D45DE5D
	for <linux-mm@kvack.org>; Fri,  7 May 2010 09:12:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B8FF1DB803E
	for <linux-mm@kvack.org>; Fri,  7 May 2010 09:12:53 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DF37B1DB803F
	for <linux-mm@kvack.org>; Fri,  7 May 2010 09:12:52 +0900 (JST)
Date: Fri, 7 May 2010 09:08:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm,compaction: Do not schedule work on other CPUs for
 compaction
Message-Id: <20100507090850.50d6a11c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100506150808.GC8704@csn.ul.ie>
References: <20100506150808.GC8704@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 May 2010 16:08:09 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> Migration normally requires a call to migrate_prep() as a preparation
> step. This schedules work on all CPUs for pagevecs to be drained. This
> makes sense for move_pages and memory hot-remove but is unnecessary
> for memory compaction.
> 
> To avoid queueing work on multiple CPUs, this patch introduces
> migrate_prep_local() which drains just local pagevecs.
> 
> This patch can be either merged with mmcompaction-memory-compaction-core.patch
> or placed immediately after it to clarify why migrate_prep_local() was
> introduced.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
