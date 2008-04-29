Message-ID: <48167B22.4060704@cn.fujitsu.com>
Date: Tue, 29 Apr 2008 09:34:26 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/8] memcg: read_mostly
References: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com> <20080428202652.b00f28da.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080428202652.b00f28da.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> These 3 params are read_mostly.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
> Index: mm-2.6.25-mm1/mm/memcontrol.c
> ===================================================================
> --- mm-2.6.25-mm1.orig/mm/memcontrol.c
> +++ mm-2.6.25-mm1/mm/memcontrol.c
> @@ -35,9 +35,9 @@
>  
>  #include <asm/uaccess.h>
>  
> -struct cgroup_subsys mem_cgroup_subsys;
> -static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
> -static struct kmem_cache *page_cgroup_cache;
> +struct cgroup_subsys mem_cgroup_subsys __read_mostly;
> +static const int MEM_CGROUP_RECLAIM_RETRIES __read_mostly = 5;

it's not __read_mostly, it's __read_always. ;)
so why not make it a macro:
	#define MEM_CGROUP_RECLAIM_RETRIES	5

> +static struct kmem_cache *page_cgroup_cache __read_mostly;
>  
>  /*
>   * Statistics for memory cgroup.
> 
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
