Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 548986B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 02:08:29 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBL78QDf025684
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 21 Dec 2009 16:08:26 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 81D1745DE56
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:08:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C0B445DE4E
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:08:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F40B1DB8048
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:08:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C0B0F1DB8044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:08:25 +0900 (JST)
Date: Mon, 21 Dec 2009 16:05:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 8/8] memcg: improve performance in moving swap
 charge
Message-Id: <20091221160520.d5c68c52.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091221144006.65319085.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221144006.65319085.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 14:40:06 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch tries to reduce overheads in moving swap charge by:
> 
> - Adds a new function(__mem_cgroup_put), which takes "count" as a arg and
>   decrement mem->refcnt by "count".
> - Removed res_counter_uncharge, css_put, and mem_cgroup_put from the path
>   of moving swap account, and consolidate all of them into mem_cgroup_clear_mc.
>   We cannot do that about mc.to->refcnt.
> 
> These changes reduces the overhead from 1.35sec to 0.9sec to move charges of 1G
> anonymous memory(including 500MB swap) in my test environment.
> 
> Changelog: 2009/12/21
> - don't postpone calling mem_cgroup_get() against the new cgroup(bug fix).
> Changelog: 2009/12/04
> - new patch
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
