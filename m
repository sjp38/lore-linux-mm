Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B3CB28D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 19:17:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AA8AB3EE0BC
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:17:05 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F10845DE67
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:17:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7544245DE61
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:17:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CA021DB803F
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:17:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28DE01DB8038
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:17:05 +0900 (JST)
Date: Fri, 4 Feb 2011 09:10:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 4/5] memcg: condense page_cgroup-to-page lookup points
Message-Id: <20110204091058.2a733a1a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1296743166-9412-5-git-send-email-hannes@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
	<1296743166-9412-5-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  3 Feb 2011 15:26:05 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> The per-cgroup LRU lists string up 'struct page_cgroup's.  To get from
> those structures to the page they represent, a lookup is required.
> Currently, the lookup is done through a direct pointer in struct
> page_cgroup, so a lot of functions down the callchain do this lookup
> by themselves instead of receiving the page pointer from their
> callers.
> 
> The next patch removes this pointer, however, and the lookup is no
> longer that straight-forward.  In preparation for that, this patch
> only leaves the non-optional lookups when coming directly from the LRU
> list and passes the page down the stack.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Maybe good.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
