Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id F3E9F6B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 21:50:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8BFEF3EE0AE
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:50:11 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7516245DE4F
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:50:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C9BF45DE4E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:50:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F0901DB8040
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:50:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 08EE31DB803B
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:50:11 +0900 (JST)
Message-ID: <4F6BD671.4040902@jp.fujitsu.com>
Date: Fri, 23 Mar 2012 10:48:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 6/7] mm/memcg: kill mem_cgroup_lru_del()
References: <20120322214944.27814.42039.stgit@zurg> <20120322215639.27814.4996.stgit@zurg>
In-Reply-To: <20120322215639.27814.4996.stgit@zurg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

(2012/03/23 6:56), Konstantin Khlebnikov wrote:

> This patch kills mem_cgroup_lru_del(), we can use mem_cgroup_lru_del_list()
> instead. On 0-order isolation we already have right lru list id.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Hugh Dickins <hughd@google.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
