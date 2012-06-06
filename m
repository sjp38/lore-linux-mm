Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 896D66B0062
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 03:18:35 -0400 (EDT)
Date: Wed, 6 Jun 2012 09:18:09 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] rename MEM_CGROUP_STAT_SWAPOUT as
 MEM_CGROUP_STAT_SWAP
Message-ID: <20120606071809.GD1761@cmpxchg.org>
References: <4FCD609E.8070704@jp.fujitsu.com>
 <4FCD61CA.6010209@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FCD61CA.6010209@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org

On Tue, Jun 05, 2012 at 10:32:58AM +0900, Kamezawa Hiroyuki wrote:
> 
> MEM_CGROUP_STAT_SWAPOUT represents the usage of swap rather than
> the number of swap-out events. Rename it to be MEM_CGROUP_STAT_SWAP.
> 
> Changelog:
>  - use MEM_CGROUP_STAT_SWAP instead of MEM_CGROUP_STAT_NR_SWAP.
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
