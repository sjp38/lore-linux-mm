Date: Wed, 20 Feb 2008 10:55:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080220105538.6e7bbaba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802191605500.16579@blonde.site>
References: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
	<20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	<17878602.1203436460680.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802191605500.16579@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Balbir-san,

On Tue, 19 Feb 2008 16:26:10 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:
> @@ -575,9 +532,11 @@ static int mem_cgroup_charge_common(stru
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> +	struct page_cgroup *new_pc = NULL;
>  	unsigned long flags;
>  	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  	struct mem_cgroup_per_zone *mz;
> +	int error;
>  
>  	/*
>  	 * Should page_cgroup's go to their own slab?
> @@ -586,31 +545,20 @@ static int mem_cgroup_charge_common(stru
>  	 * to see if the cgroup page already has a page_cgroup associated
>  	 * with it
>  	 */
> -retry:
> +
>  	if (page) {
> +		error = 0;
>  		lock_page_cgroup(page);

What is !page case in mem_cgroup_charge_xxx() ?

Thanks
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
