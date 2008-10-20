Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9K0OYxO024784
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 20 Oct 2008 09:24:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E17B53C161
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 09:24:34 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 40117240060
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 09:24:34 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D1651DB803B
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 09:24:34 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id DF8E91DB8038
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 09:24:33 +0900 (JST)
Date: Mon, 20 Oct 2008 09:24:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH -mm 0/5] mem+swap resource controller(trial patch)
Message-Id: <20081020092409.67d34506.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 17 Oct 2008 19:48:04 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> I think Kamezawa-san is working on this now, I also made
> a trial patch based on Kamezawa-san's v2.
> 
yes, I'm now rewriting. I'm now considering whether we can implement easier
protocol or not. But your patch's direction is not far from mine.

> Unfortunately this patch doesn't work(I'll investigate),
> but I post it to promote discussion on this topic.
> 
What kind of problems ? accounting is not correct ?


> Major changes from v2:
> - rebased on memcg-update-v7.
> - add a counter to count real swap usage(# of swap entries).
> - add arg "use_swap" to try_to_mem_cgroup_pages() and use it sc->may_swap.
> 
> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
