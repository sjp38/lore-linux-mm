Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id EBC906B005D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 12:53:35 -0400 (EDT)
Date: Fri, 1 Jun 2012 18:53:20 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] rename MEM_CGROUP_STAT_SWAPOUT as MEM_CGROUP_STAT_NR_SWAP
Message-ID: <20120601165320.GA1761@cmpxchg.org>
References: <4FC89BC4.9030604@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FC89BC4.9030604@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, akpm@linux-foundation.org

On Fri, Jun 01, 2012 at 07:39:00PM +0900, Kamezawa Hiroyuki wrote:
> MEM_CGROUP_STAT_SWAPOUT represents the usage of swap rather than
> the number of swap-out events. Rename it to be MEM_CGROUP_STAT_NR_SWAP.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Wouldn't MEM_CGROUP_STAT_SWAP be better?  It's equally descriptive but
matches the string.  And we also don't have NR_ for cache, rss, mapped
file etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
