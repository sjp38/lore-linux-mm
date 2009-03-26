Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4BCBB6B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 02:02:50 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2Q6q1TO017404
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Mar 2009 15:52:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id ACA6D45DD72
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 15:52:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 91BB245DE4F
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 15:52:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 851571DB803E
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 15:52:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 343641DB8040
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 15:52:00 +0900 (JST)
Date: Thu, 26 Mar 2009 15:50:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix shrink_usage
Message-Id: <20090326155035.826cb2ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090326153803.23689561.nishimura@mxp.nes.nec.co.jp>
References: <20090326130821.40c26cf1.nishimura@mxp.nes.nec.co.jp>
	<20090326141246.32305fe5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090326145148.ba722e1e.nishimura@mxp.nes.nec.co.jp>
	<20090326150613.09aacf0d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090326151733.1e36bf43.nishimura@mxp.nes.nec.co.jp>
	<20090326152734.365b8689.kamezawa.hiroyu@jp.fujitsu.com>
	<20090326153803.23689561.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Mar 2009 15:38:03 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:


> > Seems very simple. hmm, I'm thinking of following.
> > ==
> > int mem_cgroup_shmem_charge_fallback(struct page *page, struct mm_struct *mm, gfp_t mask)
> > {
> > 	return mem_cgroup_cache_charge(mm, page, mask);
> > }
> > ==
> > 
> > But I'm afraid that this adds another corner case to account the page not under
> > radix-tree. (But this is SwapCache...then...this will work.)
> > 
> > Could you write a patch in this direction ? (or I'll write by myself.)
> > It's obvious that you do better test.
> > 
> Okey.
> 
> I'll make a patch and repost it after doing some tests for review.
> 
> BTW, do you have any good idea about the new name of shrink_usage ?
> 
See above ;) mem_cgroup_shmem_charge_fallback() seems to be straightforward.
I'm glad if you rewrite the comment to function at the same time :)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
