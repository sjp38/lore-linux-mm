Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6C0088D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 19:09:13 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 84ED63EE0BD
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:09:11 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 699C545DE57
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:09:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5185C45DE55
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:09:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 442C71DB8038
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:09:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D576E08003
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 09:09:11 +0900 (JST)
Date: Fri, 4 Feb 2011 09:03:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/5] memcg: change page_cgroup_zoneinfo signature
Message-Id: <20110204090307.38d7a7ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1296743166-9412-3-git-send-email-hannes@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
	<1296743166-9412-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  3 Feb 2011 15:26:03 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Instead of passing a whole struct page_cgroup to this function, let it
> take only what it really needs from it: the struct mem_cgroup and the
> page.
> 
> This has the advantage that reading pc->mem_cgroup is now done at the
> same place where the ordering rules for this pointer are enforced and
> explained.
> 
> It is also in preparation for removing the pc->page backpointer.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
