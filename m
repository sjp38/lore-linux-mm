Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C835E6B008C
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 19:07:25 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 08B0D3EE0B6
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:07:23 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD95245DE51
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:07:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C6F1B45DE4D
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:07:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B885CE08001
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:07:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 842CE1DB8037
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 09:07:22 +0900 (JST)
Date: Thu, 24 Nov 2011 09:06:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 6/8] mm: memcg: remove unneeded checks from
 uncharge_page()
Message-Id: <20111124090619.895988e7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322062951-1756-7-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
	<1322062951-1756-7-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Nov 2011 16:42:29 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> From: Johannes Weiner <jweiner@redhat.com>
> 
> mem_cgroup_uncharge_page() is only called on either freshly allocated
> pages without page->mapping or on rmapped PageAnon() pages.  There is
> no need to check for a page->mapping that is not an anon_vma.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

For making our assumption clearer to readers of codes,
VM_BUG_ON(page->mapping && !PageAnon(page)) please.

Anyway,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/memcontrol.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0d10be4..b9a3b94 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2989,8 +2989,6 @@ void mem_cgroup_uncharge_page(struct page *page)
>  	/* early check. */
>  	if (page_mapped(page))
>  		return;
> -	if (page->mapping && !PageAnon(page))
> -		return;
>  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
>  }
>  
> -- 
> 1.7.6.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
