Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 48D246B0069
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 09:01:46 -0400 (EDT)
Date: Tue, 10 Jul 2012 15:01:33 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] shmem: cleanup shmem_add_to_page_cache
Message-ID: <20120710130133.GF1779@cmpxchg.org>
References: <alpine.LSU.2.00.1207091533001.2051@eggly.anvils>
 <alpine.LSU.2.00.1207091544290.2051@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207091544290.2051@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 09, 2012 at 03:46:53PM -0700, Hugh Dickins wrote:
> shmem_add_to_page_cache() has three callsites, but only one of them
> wants the radix_tree_preload() (an exceptional entry guarantees that
> the radix tree node is present in the other cases), and only that site
> can achieve mem_cgroup_uncharge_cache_page() (PageSwapCache makes it a
> no-op in the other cases).  We did it this way originally to reflect
> add_to_page_cache_locked(); but it's confusing now, so move the
> radix_tree preloading and mem_cgroup uncharging to that one caller.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

I'm rebasing my (un)charge series on top of these, thanks.  It only
annihilates 3/11 and leaves the rest alone--line numbers aside--since
the rules did not change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
