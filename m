Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 85B036B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:28:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 12B103EE0BD
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:28:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EF1CF45DE4D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:28:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C54B045DE4F
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:28:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A9EB11DB8040
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:28:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E9AA1DB802F
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 14:28:08 +0900 (JST)
Date: Tue, 13 Mar 2012 14:26:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 4.5/7] mm: optimize isolate_lru_pages()
Message-Id: <20120313142635.a6a7b806.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120311141334.29756.79407.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
	<20120311141334.29756.79407.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Sun, 11 Mar 2012 18:36:16 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This patch moves lru checks from __isolate_lru_page() to its callers.
> 
> They aren't required on non-lumpy reclaim: all pages are came from right lru.
> Pages isolation on memory compaction should skip only unevictable pages.
> Thus we need to check page lru only on pages isolation for lumpy-reclaim.
> 
> Plus this patch kills mem_cgroup_lru_del() and uses mem_cgroup_lru_del_list()
> instead, because now we already have lru list index.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> 
> add/remove: 0/1 grow/shrink: 2/1 up/down: 101/-164 (-63)
> function                                     old     new   delta
> static.isolate_lru_pages                    1018    1103     +85
> compact_zone                                2230    2246     +16
> mem_cgroup_lru_del                            65       -     -65
> __isolate_lru_page                           287     188     -99


Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
