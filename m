Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 129476B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 04:22:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3D8MsUr015905
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Apr 2010 17:22:55 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CEBE845DE51
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:22:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF79245DE50
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:22:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 987F9E08001
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:22:54 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5367EE08004
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:22:51 +0900 (JST)
Date: Tue, 13 Apr 2010 17:19:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
Message-Id: <20100413171903.ea4d8215.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue,  6 Apr 2010 10:59:37 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> In funtion migrate_pages(), if the dest node have no
> enough free pages,it will fallback to other nodes.
> Add GFP_THISNODE to avoid this, the same as what
> funtion new_page_node() do in migrate.c.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/mempolicy.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 08f40a2..fc5ddf5 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>  
>  static struct page *new_node_page(struct page *page, unsigned long node, int **x)
>  {
> -	return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
> +	return alloc_pages_exact_node(node,
> +				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
>  }
>  
>  /*
> -- 
> 1.5.6.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
