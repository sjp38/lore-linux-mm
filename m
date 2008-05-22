Date: Thu, 22 May 2008 17:00:14 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] swapcgroup: modify vm_swap_full for cgroup
In-Reply-To: <48351120.6000800@mxp.nes.nec.co.jp>
References: <48350F15.9070007@mxp.nes.nec.co.jp> <48351120.6000800@mxp.nes.nec.co.jp>
Message-Id: <20080522165322.F516.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi,

> +#ifndef CONFIG_CGROUP_SWAP_RES_CTLR
>  /* Swap 50% full? Release swapcache more aggressively.. */
> -#define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
> +#define vm_swap_full(page) (nr_swap_pages*2 < total_swap_pages)
> +#else
> +#define vm_swap_full(page) swap_cgroup_vm_swap_full(page)
> +#endif

I'd prefer #ifdef rather than #ifndef.

so...

#ifdef CONFIG_CGROUP_SWAP_RES_CTLR
  your definition
#else
  original definition
#endif

and vm_swap_full() isn't page granularity operation.
this is memory(or swap) cgroup operation.

this argument is slightly odd.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
