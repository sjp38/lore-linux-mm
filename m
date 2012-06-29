Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id C2D386B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:41:13 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6017609dak.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:41:13 -0700 (PDT)
Date: Fri, 29 Jun 2012 14:41:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 2/2] memcg : remove -ENOMEM at page migration.
In-Reply-To: <4FEC308F.4020909@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1206291439080.11416@chino.kir.corp.google.com>
References: <4FEC300A.7040209@jp.fujitsu.com> <4FEC308F.4020909@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Thu, 28 Jun 2012, Kamezawa Hiroyuki wrote:

> For handling many kinds of races, memcg adds an extra charge to
> page's memcg at page migration. But this affects the page compaction
> and make it fail if the memcg is under OOM.
> 
> This patch uses res_counter_charge_nofail() in page migration path
> and remove -ENOMEM. By this, page migration will not fail by the
> status of memcg.
> 
> Reported-by: David Rientjes <rientjes@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

This is a very good improvement for page migration under memory compaction 
and increases the liklihood that it will do useful work for transparent 
hugepage allocations, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
