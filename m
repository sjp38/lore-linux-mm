Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DC9BF6B0047
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 02:06:17 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBL76EkD001090
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 21 Dec 2009 16:06:15 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C93545DE4F
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:06:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FC9C45DE4E
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:06:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 48C8C1DB8041
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:06:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 052CD1DB803C
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:06:14 +0900 (JST)
Date: Mon, 21 Dec 2009 16:03:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 6/8] memcg: avoid oom during moving charge
Message-Id: <20091221160309.b639dc25.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091221143709.112c7fad.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143709.112c7fad.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 14:37:09 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This move-charge-at-task-migration feature has extra charges on "to"(pre-charges)
> and "from"(left-over charges) during moving charge. This means unnecessary oom
> can happen.
> 
> This patch tries to avoid such oom.
> 
> Changelog: 2009/12/21
> - minor cleanup.
> Changelog: 2009/12/14
> - instead of continuing to charge by busy loop, make use of waitq.
> Changelog: 2009/12/04
> - take account of "from" too, because we uncharge from "from" at once in
>   mem_cgroup_clear_mc(), so left-over charges exist during moving charge.
> - check use_hierarchy of "mem_over_limit", instead of "to" or "from"(bugfix).
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
