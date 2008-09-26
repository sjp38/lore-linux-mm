Date: Fri, 26 Sep 2008 12:04:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/12] memcg updates v5
Message-Id: <20080926120408.39187294.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926115810.b5fbae51.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080926113228.ee377330.nishimura@mxp.nes.nec.co.jp>
	<20080926115810.b5fbae51.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 11:58:10 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Thank you.
> 
> How about following ?
> -Kame
> ==
> Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
> +++ mmotm-2.6.27-rc7+/mm/memcontrol.c
> @@ -597,8 +597,8 @@ __set_page_cgroup_lru(struct memcg_percp
>  			spin_lock(&mz->lru_lock);
>  		}
>  		if (PageCgroupUsed(pc) && !PageCgroupLRU(pc)) {
> -			SetPageCgroupLRU(pc);
>  			__mem_cgroup_add_list(mz, pc);
> +			SetPageCgroupLRU(pc);
>  		}
>  	}
>  
Of course, remove side should be..
-Kame
==
Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -564,8 +564,8 @@ __release_page_cgroup(struct memcg_percp
 			spin_lock(&mz->lru_lock);
 		}
 		if (!PageCgroupUsed(pc) && PageCgroupLRU(pc)) {
-			__mem_cgroup_remove_list(mz, pc);
 			ClearPageCgroupLRU(pc);
+			__mem_cgroup_remove_list(mz, pc);
 		}
 	}
 	if (prev_mz)
@@ -597,8 +597,8 @@ __set_page_cgroup_lru(struct memcg_percp
 			spin_lock(&mz->lru_lock);
 		}
 		if (PageCgroupUsed(pc) && !PageCgroupLRU(pc)) {
-			SetPageCgroupLRU(pc);
 			__mem_cgroup_add_list(mz, pc);
+			SetPageCgroupLRU(pc);
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
