Date: Thu, 23 Oct 2008 21:32:28 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC][PATCH 9/11] memcg : mem+swap controlelr kconfig
Message-Id: <20081023213228.bf7cc325.randy.dunlap@oracle.com>
In-Reply-To: <20081023181220.80dc24c5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023181220.80dc24c5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Oct 2008 18:12:20 +0900 KAMEZAWA Hiroyuki wrote:

>  Documentation/kernel-parameters.txt |    3 +++
>  include/linux/memcontrol.h          |    3 +++
>  init/Kconfig                        |   16 ++++++++++++++++
>  mm/memcontrol.c                     |   17 +++++++++++++++++
>  4 files changed, 39 insertions(+)
> 
> Index: mmotm-2.6.27+/init/Kconfig
> ===================================================================
> --- mmotm-2.6.27+.orig/init/Kconfig
> +++ mmotm-2.6.27+/init/Kconfig
> @@ -613,6 +613,22 @@ config KALLSYMS_EXTRA_PASS
>  	   reported.  KALLSYMS_EXTRA_PASS is only a temporary workaround while
>  	   you wait for kallsyms to be fixed.
>  
> +config CGROUP_MEM_RES_CTLR_SWAP
> +	bool "Memory Resource Controller Swap Extension(EXPERIMENTAL)"
> +	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
> +	help
> +	  Add swap management feature to memory resource controller. When you
> +	  enable this, you can limit mem+swap usage per cgroup. In other words,
> +	  when you disable this, memory resource controller have no cares to

	  probably:                                         has

> +	  usage of swap...a process can exhaust the all swap. This extension

	                                        all of the swap.

> +	  is useful when you want to avoid exhausion of swap but this itself

	                                   exhaustion

> +	  adds more overheads and consumes memory for remembering information.
> +	  Especially if you use 32bit system or small memory system,
> +	  please be careful to enable this. When memory resource controller

	  probably:         about enabling this.

> +	  is disabled by boot option, this will be automatiaclly disabled and
> +	  there will be no overhead from this. Even when you set this config=y,
> +	  if boot option "noswapaccount" is set, swap will not be accounted.
> +
>  
>  config HOTPLUG
>  	bool "Support for hot-pluggable devices" if EMBEDDED


---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
