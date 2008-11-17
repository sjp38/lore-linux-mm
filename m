Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAH5VGnv031466
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 17 Nov 2008 14:31:16 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 08EAD45DE4E
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 14:31:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D76DE45DE52
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 14:31:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B359DE0800B
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 14:31:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 54876E08001
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 14:31:15 +0900 (JST)
Date: Mon, 17 Nov 2008 14:30:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Fix typo in swap cgroup message
Message-Id: <20081117143035.58e7aa62.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081117044008.GA25269@balbir.in.ibm.com>
References: <20081117044008.GA25269@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Li Zefan <lizf@cn.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Nov 2008 10:10:08 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> There is a typo in the spelling of buffers (buffres) and the message is
> not very clear either. Fix the message and typo (hopefully not introducing
> any new ones ;) )
> 
(>_< thanks, I found my private aspell dict includes "buffres"...

-Kame

> Cc: Hugh Dickins <hugh@veritas.com>
> Cc: Li Zefan <lizf@cn.fujitsu.com>
> Cc: Pavel Emelyanov <xemul@openvz.org>
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  mm/page_cgroup.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff -puN mm/page_cgroup.c~fix-typo-swap-cgroup mm/page_cgroup.c
> --- linux-2.6.28-rc4/mm/page_cgroup.c~fix-typo-swap-cgroup	2008-11-16 20:03:28.000000000 +0530
> +++ linux-2.6.28-rc4-balbir/mm/page_cgroup.c	2008-11-17 09:59:43.000000000 +0530
> @@ -423,7 +423,8 @@ int swap_cgroup_swapon(int type, unsigne
>  	mutex_unlock(&swap_cgroup_mutex);
>  
>  	printk(KERN_INFO
> -		"swap_cgroup: uses %ld bytes vmalloc and %ld bytes buffres\n",
> +		"swap_cgroup: uses %ld bytes of vmalloc for pointer array space"
> +		" and %ld bytes to hold mem_cgroup pointers on swap\n",
>  		array_size, length * PAGE_SIZE);
>  	printk(KERN_INFO
>  	"swap_cgroup can be disabled by noswapaccount boot option.\n");
> _
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
