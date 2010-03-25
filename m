Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 62DB16B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 05:12:34 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2P9CViM026983
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 25 Mar 2010 18:12:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BC4BE45DE7C
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:12:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9290145DE70
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:12:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C10BE18008
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:12:31 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 26E15E18003
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:12:31 +0900 (JST)
Date: Thu, 25 Mar 2010 18:08:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
Message-Id: <20100325180846.c6ded3ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100325180726.6C89.A69D9226@jp.fujitsu.com>
References: <20100325083235.GF2024@csn.ul.ie>
	<20100325180221.e1d9bae7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100325180726.6C89.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Mar 2010 18:09:34 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Thu, 25 Mar 2010 08:32:35 +0000
> > Mel Gorman <mel@csn.ul.ie> wrote:

> >  IIUC, the race in memory-hotunplug was fixed by this patch [2/11].
> > 
> >  But, this behavior of unmap_and_move() requires access to _freed_
> >  objects (spinlock). Even if it's safe because of SLAB_DESTROY_BY_RCU,
> >  it't not good habit in general.
> > 
> >  After direct compaction, page-migration will be one of "core" code of
> >  memory management. Then, I agree to patch [1/11] as our direction for
> >  keeping sanity and showing direction to more updates. Maybe adding
> >  refcnt and removing RCU in futuer is good.
> 
> But Christoph seems oppose to remove SLAB_DESTROY_BY_RCU. then refcount
> is meaningless now. I agree you if we will remove SLAB_DESTROY_BY_RCU
> in the future.
> 
removing rcu_read_lock/unlock in unmap_and_move() and removing
SLAB_DESTROY_BY_RCU is different story.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
