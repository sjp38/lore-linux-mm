Subject: Re: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [3/10] per-zone active inactive counter
In-Reply-To: Your message of "Tue, 27 Nov 2007 12:00:48 +0900"
	<20071127120048.ef5f2005.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071127120048.ef5f2005.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20071129031937.3C86F1CFE80@siro.lan>
Date: Thu, 29 Nov 2007 12:19:37 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

> @@ -651,10 +758,11 @@
>  		/* Avoid race with charge */
>  		atomic_set(&pc->ref_cnt, 0);
>  		if (clear_page_cgroup(page, pc) == pc) {
> +			int active;
>  			css_put(&mem->css);
> +			active = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
>  			res_counter_uncharge(&mem->res, PAGE_SIZE);
> -			list_del_init(&pc->lru);
> -			mem_cgroup_charge_statistics(mem, pc->flags, false);
> +			__mem_cgroup_remove_list(pc);
>  			kfree(pc);
>  		} else 	/* being uncharged ? ...do relax */
>  			break;

'active' seems unused.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
