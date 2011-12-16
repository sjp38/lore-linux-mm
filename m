Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 9365E6B004F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 17:28:16 -0500 (EST)
Date: Fri, 16 Dec 2011 14:28:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] memcg: simplify page cache charging.
Message-Id: <20111216142814.dbb77209.akpm@linux-foundation.org>
In-Reply-To: <20111214164922.05fb4afe.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
	<20111214164922.05fb4afe.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed, 14 Dec 2011 16:49:22 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Because of commit ef6a3c6311, FUSE uses replace_page_cache() instead
> of add_to_page_cache(). Then, mem_cgroup_cache_charge() is not
> called against FUSE's pages from splice.

Speaking of ef6a3c6311 ("mm: add replace_page_cache_page() function"),
may I pathetically remind people that it's rather inefficient?

http://lkml.indiana.edu/hypermail/linux/kernel/1109.1/00375.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
