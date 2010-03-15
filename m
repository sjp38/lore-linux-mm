Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4B2326B018A
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 20:08:43 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2F08dXk005700
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Mar 2010 09:08:39 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 14E8B45DE56
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 09:08:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E7C8A45DE51
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 09:08:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CC9ECE18003
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 09:08:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A3901DB8043
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 09:08:38 +0900 (JST)
Date: Mon, 15 Mar 2010 09:04:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcontrol: fix potential null deref
Message-Id: <20100315090451.ebd0ea2c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100313145621.GA3569@bicker>
References: <20100313145621.GA3569@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Carpenter <error27@gmail.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>"akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, 13 Mar 2010 17:56:21 +0300
Dan Carpenter <error27@gmail.com> wrote:

> There was a potential null deref introduced in:
> c62b1a3b31b5 memcg: use generic percpu instead of private implementation
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Thanks.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7973b52..e1e0996 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3691,8 +3691,10 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  	else
>  		mem = vmalloc(size);
>  
> -	if (mem)
> -		memset(mem, 0, size);
> +	if (!mem)
> +		return NULL;
> +
> +	memset(mem, 0, size);
>  	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
>  	if (!mem->stat) {
>  		if (size < PAGE_SIZE)
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
