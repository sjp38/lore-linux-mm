Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 516568D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 18:55:46 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7C5E33EE0B6
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:55:44 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 61C9B45DE5A
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:55:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4600245DE55
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:55:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3837FE08004
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:55:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F12DBE38004
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:55:43 +0900 (JST)
Date: Fri, 4 Feb 2011 08:49:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: remove impossible conditional when committing
Message-Id: <20110204084939.c3cdec51.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110203141110.GF2286@cmpxchg.org>
References: <20110203141110.GF2286@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 3 Feb 2011 15:11:10 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> No callsite ever passes a NULL pointer for a struct mem_cgroup * to
> the committing function.  There is no need to check for it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But, could you add VM_BUG_ON(!mem) here ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
