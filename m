Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6F76B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 02:03:11 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2C7723EE0B6
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:03:08 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 131C345DE54
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:03:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D5E5545DE5B
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:03:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C8EB11DB8051
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:03:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F110E08002
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:03:07 +0900 (JST)
Date: Wed, 20 Jul 2011 14:55:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: change memcg_oom_mutex to spinlock
Message-Id: <20110720145553.7703dbcb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <b24894c23d0bb06f849822cb30726b532ea3a4c5.1310732789.git.mhocko@suse.cz>
References: <cover.1310732789.git.mhocko@suse.cz>
	<b24894c23d0bb06f849822cb30726b532ea3a4c5.1310732789.git.mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu, 14 Jul 2011 17:29:51 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> memcg_oom_mutex is used to protect memcg OOM path and eventfd interface
> for oom_control. None of the critical sections which it protects sleep
> (eventfd_signal works from atomic context and the rest are simple linked
> list resp. oom_lock atomic operations).
> Mutex is also too heavy weight for those code paths because it triggers
> a lot of scheduling. It also makes makes convoying effects more visible
> when we have a big number of oom killing because we take the lock
> mutliple times during mem_cgroup_handle_oom so we have multiple places
> where many processes can sleep.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
