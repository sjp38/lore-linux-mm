Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4ECE66B004F
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 22:00:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C20ML8030915
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 12 Mar 2009 11:00:23 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A808245DD74
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:00:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 870B845DD72
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:00:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 71E47E08004
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:00:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 299D9E08002
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:00:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may get wrongly discarded
In-Reply-To: <20090312105226.88df3f63.minchan.kim@barrios-desktop>
References: <20090312100049.43A3.A69D9226@jp.fujitsu.com> <20090312105226.88df3f63.minchan.kim@barrios-desktop>
Message-Id: <20090312105622.43A6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 12 Mar 2009 11:00:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, dhowells@redhat.com, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> Hi, Kosaki-san. 
> 
> I think ramfs pages's unevictablility should not depend on CONFIG_UNEVICTABLE_LRU.
> It would be better to remove dependency of CONFIG_UNEVICTABLE_LRU ?
> 
> How about this ? 
> It's just RFC. It's not tested. 
> 
> That's because we can't reclaim that pages regardless of whether there is unevictable list or not

maybe, your patch work.

but we can remove CONFIG_UNEVICTABLE_LRU build option itself completely 
after nommu folks confirmed CONFIG_UNEVICTABLE_LRU works well on their machine

it is more cleaner IMHO.
What do you think?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
