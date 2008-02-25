Date: Mon, 25 Feb 2008 16:06:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [8/7] vmalloc for
 large machines
Message-Id: <20080225160617.a8ca8682.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080225121959.32977eb4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225121959.32977eb4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 12:19:59 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> +#ifdef CONFIG_PAGE_CGROUP_VMALLOC
> +#define PCGRUP_BASE_SHIFT	(28)	/* covers 256M per entry */
> +#define PCGRP_SHIFT		(PCGROUP_PAGE_SHIFT - PCGRP_SHIFT)
> +#else
>  #define PCGRP_SHIFT     (8)
> +#endif
Above is broken, maybe reflesh miss...
please ignore this.

Sorry,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
