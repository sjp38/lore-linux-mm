Date: Thu, 23 Oct 2008 21:28:37 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC][PATCH 5/11] memcg: account move and change force_empty
Message-Id: <20081023212837.960db1e8.randy.dunlap@oracle.com>
In-Reply-To: <20081023180538.6fc7ee69.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023180538.6fc7ee69.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Oct 2008 18:05:38 +0900 KAMEZAWA Hiroyuki wrote:

>  Documentation/controllers/memory.txt |   12 -
>  mm/memcontrol.c                      |  277 ++++++++++++++++++++++++++---------
>  2 files changed, 214 insertions(+), 75 deletions(-)
> 
> Index: mmotm-2.6.27+/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.27+.orig/mm/memcontrol.c
> +++ mmotm-2.6.27+/mm/memcontrol.c
> @@ -538,6 +533,25 @@ nomem:
>  	return -ENOMEM;
>  }
>  
> +/**
> + * mem_cgroup_try_charge - get charge of PAGE_SIZE.
> + * @mm: an mm_struct which is charged against. (when *memcg is NULL)
> + * @gfp_mask: gfp_mask for reclaim.
> + * @memcg: a pointer to memory cgroup which is charged against.
> + *
> + * charge aginst memory cgroup pointed by *memcg. if *memcg == NULL, estimated
> + * memory cgroup from @mm is got and stored in *memcg.
> + *
> + * Retruns 0 if success. -ENOMEM at failure.

      Returns

> + * This call can invoce OOM-Killer.

                    invoke

> + */

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
