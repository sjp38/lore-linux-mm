Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AC7416B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 07:06:10 -0400 (EDT)
Date: Wed, 11 Mar 2009 11:05:55 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] use css id in swap cgroup for saving memory v5
In-Reply-To: <20090311120427.2467bd14.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0903111041260.16964@blonde.anvils>
References: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp>
 <20090310160856.77deb5c3.akpm@linux-foundation.org>
 <20090311085326.403a211d.kamezawa.hiroyu@jp.fujitsu.com>
 <isapiwc.d14e3c29.6b18.49b7092b.9bc73.52@mail.jp.nec.com>
 <20090311094739.3123b05d.kamezawa.hiroyu@jp.fujitsu.com>
 <20090311120427.2467bd14.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

Sorry, you'd prefer my input on the rest, which I've not studied, but ...

On Wed, 11 Mar 2009, KAMEZAWA Hiroyuki wrote:
...
>  
> @@ -432,7 +428,7 @@ int swap_cgroup_swapon(int type, unsigne
>  
>  	printk(KERN_INFO
>  		"swap_cgroup: uses %ld bytes of vmalloc for pointer array space"
> -		" and %ld bytes to hold mem_cgroup pointers on swap\n",
> +		" and %ld bytes to hold mem_cgroup information per swap ents\n",
>  		array_size, length * PAGE_SIZE);
>  	printk(KERN_INFO
>  	"swap_cgroup can be disabled by noswapaccount boot option.\n");

... I do get very irritated by all the screenspace these messages take
up every time I swapon.  I can see that you're following a page_cgroup
precedent, one which never bothered me because it got buried in dmesg;
and most other people wouldn't be doing swapon very often, and wouldn't
be logging to a visible screen ... but is there any chance of putting an
approximation to this info in the CGROUP_MEM_RES_CTRL_SWAP Kconfig help
text and removing these runtime messages?  How do other people feel?

I'm also disappointed that we invented such a tortuously generic boot
option as "cgroup_disable=memory", then departed from it when the very
first extension "noswapaccount" was required.  "cgroup_disable=swap"?
Probably too late.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
