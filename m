Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1F0836B0055
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 20:29:50 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBN1TlLw018228
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Dec 2008 10:29:47 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DF1445DE50
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 10:29:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8279E45DD72
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 10:29:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5927D1DB803A
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 10:29:47 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F3C9FE78006
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 10:29:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg: avoid reclaim_stat oops when disabled
In-Reply-To: <Pine.LNX.4.64.0812230116210.20371@blonde.anvils>
References: <Pine.LNX.4.64.0812230116210.20371@blonde.anvils>
Message-Id: <20081223102625.164B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Dec 2008 10:29:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  struct zone_reclaim_stat *
>  mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  {
> -	struct page_cgroup *pc = lookup_page_cgroup(page);
> -	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
> +	struct page_cgroup *pc;
> +	struct mem_cgroup_per_zone *mz;
>  
> +	if (mem_cgroup_disabled())
> +		return NULL;
> +
> +	pc = lookup_page_cgroup(page);
> +	mz = page_cgroup_zoneinfo(pc);
>  	if (!mz)
>  		return NULL;

Oops, really thanks.
this patch is defenitly needed and corrent.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


Kamezawa-san, I think memcg_test.txt should describe "cgroup_disabled=memory"
too. What do you think it?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
