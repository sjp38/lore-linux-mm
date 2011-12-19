Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 18C1E6B004F
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 10:56:17 -0500 (EST)
Date: Mon, 19 Dec 2011 16:56:13 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/4] memcg: simplify LRU handling.
Message-ID: <20111219155613.GE1415@cmpxchg.org>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed, Dec 14, 2011 at 04:47:34PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> This series is onto linux-next + 
> memcg-add-mem_cgroup_replace_page_cache-to-fix-lru-issue.patch
> 
> The 1st purpose of this patch is reduce overheads of mem_cgroup_add/del_lru.
> They uses some atomic ops.

Which is noticable.

With a simple sparse file cat, mem_cgroup_lru_add_list() went from

     1.12%      cat  [kernel.kallsyms]    [k] mem_cgroup_lru_add_list

to

     0.31%      cat  [kernel.kallsyms]    [k] mem_cgroup_lru_add_list

and real time went down, too:

5 runs		min	median	max	in seconds
vanilla:	7.762	7.782	7.816
patched:	7.622	7.631	7.660

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
