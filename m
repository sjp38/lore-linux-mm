Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 2D56F6B02A5
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 04:15:29 -0400 (EDT)
Date: Sat, 23 Jun 2012 10:15:14 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/6] memcg: replace unsigned long by u64 to avoid overflow
Message-ID: <20120623081514.GJ27816@cmpxchg.org>
References: <1340432134-5178-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340432134-5178-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

On Sat, Jun 23, 2012 at 02:15:34PM +0800, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Since the return value variable in mem_cgroup_zone_nr_lru_pages and
> mem_cgroup_node_nr_lru_pages functions are u64, so replace the return
> value of funtions by u64 to avoid overflow.

I wonder what 16 TB of memory must think running on a 32-bit kernel...
"What is this, an address space for ants?"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
