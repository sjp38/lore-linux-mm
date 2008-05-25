Subject: Re: [PATCH 4/4] swapcgroup: modify vm_swap_full for cgroup
In-Reply-To: Your message of "Thu, 22 May 2008 21:34:50 +0900"
	<4835686A.9000106@mxp.nes.nec.co.jp>
References: <4835686A.9000106@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080525233532.1EE145A0E@siro.lan>
Date: Mon, 26 May 2008 08:35:32 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: containers@lists.osdl.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, riel@redhat.com, balbir@linux.vnet.ibm.com, kosaki.motohiro@jp.fujitsu.com, hugh@veritas.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> How about something like this?
> 
>   :
> usage = swap_cgroup_read_usage(mem);	//no need to align to number of page
> limit = swap_cgroup_read_limit(mem);	//no need to align to number of page
> ret = (usage * 2 > limit) || (nr_swap_pages * 2 < total_swap_pages)
>   :

it seems reasonable to me.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
