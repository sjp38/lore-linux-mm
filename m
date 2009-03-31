Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 373C26B003D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 20:01:55 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2V01r9i013551
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 09:01:53 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AF0945DE52
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 09:01:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5640845DE4F
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 09:01:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 257A91DB8043
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 09:01:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AD81AE08009
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 09:01:51 +0900 (JST)
Date: Tue, 31 Mar 2009 09:00:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 7/8] memcg soft limit LRU reorder
Message-Id: <20090331090023.e1d30a5a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090330075246.GA16497@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090327141225.1e483acd.kamezawa.hiroyu@jp.fujitsu.com>
	<20090330075246.GA16497@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Mar 2009 13:22:46 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 14:12:25]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > This patch adds a function to change the LRU order of pages in global LRU
> > under control of memcg's victim of soft limit.
> > 
> > FILE and ANON victim is divided and LRU rotation will be done independently.
> > (memcg which only includes FILE cache or ANON can exists.)
> > 
> > The routine finds specfied number of pages from memcg's LRU and
> > move it to top of global LRU. They will be the first target of shrink_xxx_list.
> 
> This seems to be the core of the patch, but I don't like this very
> much. Moving LRU pages of the mem cgroup seems very subtle, why can't
> we directly use try_to_free_mem_cgroup_pages()?
> 
It ignores many things.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
