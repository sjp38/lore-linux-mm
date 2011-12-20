Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 93C656B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 18:11:15 -0500 (EST)
Date: Tue, 20 Dec 2011 15:11:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] memcg: malloc memory for possible node in hotplug
Message-Id: <20111220151113.8aa05166.akpm@linux-foundation.org>
In-Reply-To: <1324375503-31487-1-git-send-email-lliubbo@gmail.com>
References: <1324375503-31487-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hannes@cmpxchg.org, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, bsingharora@gmail.com

On Tue, 20 Dec 2011 18:05:03 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> Current struct mem_cgroup_per_node and struct mem_cgroup_tree_per_node are
> malloced for all possible node during system boot.
> 
> This may cause some memory waste, better if move it to memory hotplug.

This adds a fair bit of complexity for what I suspect is a pretty small
memory saving.  And that memory saving will be on pretty large machines.

Can you please estimate how much memory this change will save?  Taht
way we can decide whether the additional complexity is worthwhile.


Also, the operations in the new memcg_mem_hotplug_callback() are
copied-n-pasted from other places in memcontrol.c, such as from
mem_cgroup_soft_limit_tree_init().  We shouldn't do this - we should be
able to factor the code so that both mem_cgroup_create() and
memcg_mem_hotplug_callback() emit simple calls to common helper
functions.

Thirdly, please don't forget to run scripts/checkpatch.pl!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
