Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4CE7D6B0062
	for <linux-mm@kvack.org>; Wed, 27 May 2009 02:44:23 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4R6j2S4020021
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 27 May 2009 15:45:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AAF845DD80
	for <linux-mm@kvack.org>; Wed, 27 May 2009 15:45:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E27E945DD7E
	for <linux-mm@kvack.org>; Wed, 27 May 2009 15:45:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 829101DB803C
	for <linux-mm@kvack.org>; Wed, 27 May 2009 15:45:01 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 16D1DE08002
	for <linux-mm@kvack.org>; Wed, 27 May 2009 15:45:01 +0900 (JST)
Date: Wed, 27 May 2009 15:43:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: fix swap account (26/May)[0/5]
Message-Id: <20090527154327.0926fc23.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 2009 12:12:59 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> [1/5] change interface of swap_duplicate()/swap_free()
>     Adds an function swapcache_prepare() and swapcache_free().
> 
> [2/5] add SWAP_HAS_CACHE flag to swap_map
>     Add SWAP_HAS_CACHE flag to swap_map array for knowing an information that
>     "there is an only swap cache and swap has no reference" 
>     without calling find_get_page().
> 
> [3/5] Count the number of swap-cache-only swaps
>     After repeating swap-in/out, there are tons of cache-only swaps.
>    (via a mapped swapcache under vm_swap_full()==false)
>     This patch counts the number of entry and show it in debug information.
>    (for example, sysrq-m)
> 
> [4/5] fix memcg's swap accounting.
>     change the memcg's swap accounting logic to see # of references to swap.
> 
> [5/5] experimental garbage collection for cache-only swaps.
>     reclaim swap enty which is not used.
> 

Thank you for all reviews. I'll repost when new mmotm comes. 
maybe
[1/5] ... nochage
[2/5] ... fix the bug Nishimura-san pointed out
[3/5] ... drop
[4/5] ... no change
[5/5] ... will use direct reclaim in get_swap_page().

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
