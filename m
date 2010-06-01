Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 03FAB6B01D6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 09:24:53 -0400 (EDT)
Date: Tue, 1 Jun 2010 22:24:49 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][3/3] memcg swap accounts remove experimental
Message-Id: <20100601222449.e0ac1ff2.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20100601182936.36ea72b9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
	<20100601182720.f1562de6.kamezawa.hiroyu@jp.fujitsu.com>
	<20100601182936.36ea72b9.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010 18:29:36 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> It has benn a year since we changed swap_map[] to indicates SWAP_HAS_CACHE.
> By that, memcg's swap accounting has been very stable and it seems
> it can be maintained. 
> 
> So, I'd like to remove EXPERIMENTAL from the config.
> 
I agree.

> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

> ---
>  init/Kconfig |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: mmotm-2.6.34-May21/init/Kconfig
> ===================================================================
> --- mmotm-2.6.34-May21.orig/init/Kconfig
> +++ mmotm-2.6.34-May21/init/Kconfig
> @@ -577,8 +577,8 @@ config CGROUP_MEM_RES_CTLR
>  	  could in turn add some fork/exit overhead.
>  
>  config CGROUP_MEM_RES_CTLR_SWAP
> -	bool "Memory Resource Controller Swap Extension(EXPERIMENTAL)"
> -	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
> +	bool "Memory Resource Controller Swap Extension"
> +	depends on CGROUP_MEM_RES_CTLR && SWAP
>  	help
>  	  Add swap management feature to memory resource controller. When you
>  	  enable this, you can limit mem+swap usage per cgroup. In other words,
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
