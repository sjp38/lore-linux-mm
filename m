Message-ID: <47DDD246.60600@cn.fujitsu.com>
Date: Mon, 17 Mar 2008 11:07:02 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] re-define page_cgroup.
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314190313.e6e00026.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080314190313.e6e00026.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> (This is one of a series of patch for "lookup page_cgroup" patches..)
> 
>  * Exporting page_cgroup definition.
>  * Remove page_cgroup member from sturct page.
>  * As result, PAGE_CGROUP_LOCK_BIT and assign/access functions are removed.
> 
> Other chages will appear in following patches.
> There is a change in the structure itself, spin_lock is added.
> 
> Changelog:
>  - adjusted to rc5-mm1
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
>  include/linux/memcontrol.h  |   11 --------
>  include/linux/mm_types.h    |    3 --
>  include/linux/page_cgroup.h |   47 +++++++++++++++++++++++++++++++++++
>  mm/memcontrol.c             |   59 --------------------------------------------
>  mm/page_alloc.c             |    8 -----
>  5 files changed, 48 insertions(+), 80 deletions(-)
> 
> Index: mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> ===================================================================
> --- /dev/null
> +++ mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> @@ -0,0 +1,47 @@
> +#ifndef __LINUX_PAGE_CGROUP_H
> +#define __LINUX_PAGE_CGROUP_H
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/*
> + * page_cgroup is yet another mem_map structure for accounting  usage.

                                                      two spaces ^^

> + * but, unlike mem_map, allocated on demand for accounted pages.
> + * see also memcontrol.h
> + * In nature, this cosumes much amount of memory.
> + */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
