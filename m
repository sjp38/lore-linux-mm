Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id A536B6B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 21:48:35 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B0C393EE0B5
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:48:33 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 82E6545DE50
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:48:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6ABA645DD78
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:48:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 52DD2E08002
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:48:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F21B31DB803A
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:48:32 +0900 (JST)
Message-ID: <4F6BD60F.8040508@jp.fujitsu.com>
Date: Fri, 23 Mar 2012 10:46:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 5/7] mm: remove lru type checks from __isolate_lru_page()
References: <20120322214944.27814.42039.stgit@zurg> <20120322215635.27814.30008.stgit@zurg>
In-Reply-To: <20120322215635.27814.30008.stgit@zurg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

(2012/03/23 6:56), Konstantin Khlebnikov wrote:

> After patch "mm: forbid lumpy-reclaim in shrink_active_list()" we can completely
> remove anon/file and active/inactive lru type filters from __isolate_lru_page(),
> because isolation for 0-order reclaim always isolates pages from right lru list.
> And pages-isolation for lumpy shrink_inactive_list() or memory-compaction anyway
> allowed to isolate pages from all evictable lru lists.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Hugh Dickins <hughd@google.com>
> 

seems reasonable to me.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
