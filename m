Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 15B568D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 18:49:19 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4A6223EE0BD
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:49:16 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 32AA645DD74
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:49:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 119C145DE4D
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:49:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 026261DB8038
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:49:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C34A91DB803A
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 08:49:15 +0900 (JST)
Date: Thu, 10 Feb 2011 08:42:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: charged pages always have valid per-memcg zone
 info
Message-Id: <20110210084258.55e158fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1297248275-23521-1-git-send-email-hannes@cmpxchg.org>
References: <1297248275-23521-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  9 Feb 2011 11:44:35 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> page_cgroup_zoneinfo() will never return NULL for a charged page,
> remove the check for it in mem_cgroup_get_reclaim_stat_from_page().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

IIUC, this _was_ required when force_empty() had troubles.
But now, not required.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
