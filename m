Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 932046B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 10:04:52 -0500 (EST)
Date: Mon, 19 Dec 2011 16:04:41 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/4] memcg: simplify page cache charging.
Message-ID: <20111219150441.GA1415@cmpxchg.org>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
 <20111214164922.05fb4afe.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111214164922.05fb4afe.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed, Dec 14, 2011 at 04:49:22PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This patch is a clean up. No functional/logical changes.
> 
> Because of commit ef6a3c6311, FUSE uses replace_page_cache() instead
> of add_to_page_cache(). Then, mem_cgroup_cache_charge() is not
> called against FUSE's pages from splice.
> 
> So, Now, mem_cgroup_cache_charge() doesn't receive a page on LRU
> unless it's not SwapCache.
> For checking, WARN_ON_ONCE(PageLRU(page)) is added.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I like this.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
