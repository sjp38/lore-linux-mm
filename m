Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 34EE28D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 19:07:51 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AC0393EE0B6
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:07:48 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FAE445DE59
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:07:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7702E45DE55
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:07:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 69768E38002
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:07:48 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FC7EE08002
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:07:48 +0900 (JST)
Date: Fri, 4 Feb 2011 09:01:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 1/5] memcg: no uncharged pages reach
 page_cgroup_zoneinfo
Message-Id: <20110204090145.7f1918fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1296743166-9412-2-git-send-email-hannes@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
	<1296743166-9412-2-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  3 Feb 2011 15:26:02 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> All callsites check PCG_USED before passing pc->mem_cgroup, so the
> latter is never NULL.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I want BUG_ON() here.


> ---
>  mm/memcontrol.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e071d7e..85b4b5a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -370,9 +370,6 @@ page_cgroup_zoneinfo(struct page_cgroup *pc)
>  	int nid = page_cgroup_nid(pc);
>  	int zid = page_cgroup_zid(pc);
>  
> -	if (!mem)
> -		return NULL;
> -
>  	return mem_cgroup_zoneinfo(mem, nid, zid);
>  }
>  
> -- 
> 1.7.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
