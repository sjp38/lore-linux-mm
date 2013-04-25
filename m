Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BDDC46B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 17:55:14 -0400 (EDT)
Date: Thu, 25 Apr 2013 14:55:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, memcg: add anon_hugepage stat
Message-Id: <20130425145511.68b278d2731846a6502ecc36@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, 25 Apr 2013 14:41:17 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> This exports the amount of anonymous transparent hugepages for each memcg
> via memory.stat in bytes.
> 
> This is helpful to determine the hugepage utilization for individual jobs
> on the system in comparison to rss and opportunities where MADV_HUGEPAGE
> may be helpful.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  include/linux/memcontrol.h |  3 ++-
>  mm/huge_memory.c           |  2 ++
>  mm/memcontrol.c            | 13 +++++++++----
>  mm/rmap.c                  | 18 +++++++++++++++---

And Documentation/cgroups/memory.txt, please.

> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
>
> ...
>
> +	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
>
> ...
>
>  	"mapped_file",

That "FILE_MAPPED" is presented to the user as "mapped_file" makes me
want to chew my desk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
