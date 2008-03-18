Date: Tue, 18 Mar 2008 19:22:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] Block I/O tracking
Message-Id: <20080318192233.89c5cc3e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080318.182906.104806991.taka@valinux.co.jp>
References: <20080318.182251.93858044.taka@valinux.co.jp>
	<20080318.182906.104806991.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 18:29:06 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

> Hi,
> 
> This patch implements the bio cgroup on the memory cgroup.
> 
> Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>
> 
> 
> --- linux-2.6.25-rc5.pagecgroup2/include/linux/memcontrol.h	2008-03-18 12:45:14.000000000 +0900
> +++ linux-2.6.25-rc5-mm1/include/linux/memcontrol.h	2008-03-18 12:55:59.000000000 +0900
> @@ -54,6 +54,10 @@ struct page_cgroup {
>  	struct list_head lru;		/* per cgroup LRU list */
>  	struct mem_cgroup *mem_cgroup;
>  #endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +#ifdef  CONFIG_CGROUP_BIO
> +	struct list_head blist;		/* for bio_cgroup page list */
> +	struct bio_cgroup *bio_cgroup;
> +#endif

Hmm, definition like this
==
enum {
#ifdef CONFIG_CGROUP_MEM_RES_CTLR
	MEM_RES_CTLR,
#endif
#ifdef CONFIG_CGROURP_BIO
	BIO_CTLR,
#endif
	NR_VM_CTRL,
};

	void	*cgroups[NR_VM_CGROUP];
==
Can save another #ifdefs ?

And, blist seems to be just used for force_empty.
Do you really need this ? no alternative ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
