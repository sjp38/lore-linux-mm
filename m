Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AD2936B00D1
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 02:18:28 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n227IQkN030395
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Mar 2009 16:18:26 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AA7645DE54
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 16:18:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0177245DE4E
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 16:18:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2C2E1DB8041
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 16:18:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BC981DB8040
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 16:18:24 +0900 (JST)
Date: Mon, 2 Mar 2009 16:17:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-Id: <20090302161708.beae2dd6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
	<20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302044043.GC11421@balbir.in.ibm.com>
	<20090302143250.f47758f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302060519.GG11421@balbir.in.ibm.com>
	<20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302063649.GJ11421@balbir.in.ibm.com>
	<20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Mar 2009 16:06:02 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  Considering above 2, it's not bad to find victim by proper logic
>  from balance_pgdat() by using mem_cgroup_select_victim().
>  like this:
> ==
>  struct mem_cgroup *select_vicitim_at_soft_limit_via_balance_pgdat(int nid, int zid)
>  {
>      while (?) {
>         vitcim = mem_cgroup_select_victim(init_mem_cgroup);  #need some modification.

Another choice is that when a user set soft-limit via interface, add it to
our own private list and scan it here. (of course, remove at rmdir.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
