Date: Thu, 3 Jul 2008 11:38:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm] [0/7] misc memcg patch set
Message-Id: <20080703113828.f541d562.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jul 2008 21:03:22 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Other patches in plan (including other guy's)
> - soft-limit (Balbir works.)
>   I myself think memcg-background-job patches can copperative with this.
> 
> - dirty_ratio for memcg. (haven't written at all)
>   Support dirty_ratio for memcg. This will improve OOM avoidance.
> 
> - swapiness for memcg (had patches..but have to rewrite.)
>   Support swapiness per memcg. (of no use ?)
> 
> - swap_controller (Maybe Nishimura works on.)
>   The world may change after this...cgroup without swap can appears easily.
> 
> - hierarchy (needs more discussion. maybe after OLS?)
>   have some pathes, but not in hurry.
> 
> - more performance improvements (we need some trick.)
>   = Can we remove lock_page_cgroup() ?
>   = Can we reduce spinlocks ?
> 
> - move resource at task move (needs helps from cgroup)
>   We need some magical way. It seems impossible to implement this only by memcg.
> 
> - NUMA statistics (needs helps from cgroup)
>   It seems dynamic file creation feature or some rule to show array of
>   statistics should be defined.
> 
> - memory guarantee (soft-mlock.)
>   guard parameter against global LRU for saying "Don't reclaim from me more ;("
>   Maybe HA Linux people will want this....
> 
> Do you have others ?
> 

+ hugepage handling.
  Currently hugepage is charged as PAGE_SIZE page....it's a BUG.
  At first, it seems we have to avoid charging PG_compund page.
  (until multi-size page cache is introduced.)

  I think hugepage itself is an other resource than memcg deals with. The total
  amount ot it is controlled by sysctl.
 
  Should we add hugepage controller or memrlimit controller will handle it ?
  Or just ignore hugepage ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
