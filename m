Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 077DE6B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 19:02:35 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BFA073EE0C1
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 09:02:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0FCA45DEAD
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 09:02:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8834645DEA6
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 09:02:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A06D1DB803B
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 09:02:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F86E1DB8041
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 09:02:33 +0900 (JST)
Date: Mon, 19 Dec 2011 09:01:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] memcg: simplify page cache charging.
Message-Id: <20111219090122.66024659.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111216142814.dbb77209.akpm@linux-foundation.org>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
	<20111214164922.05fb4afe.kamezawa.hiroyu@jp.fujitsu.com>
	<20111216142814.dbb77209.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Fri, 16 Dec 2011 14:28:14 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 14 Dec 2011 16:49:22 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Because of commit ef6a3c6311, FUSE uses replace_page_cache() instead
> > of add_to_page_cache(). Then, mem_cgroup_cache_charge() is not
> > called against FUSE's pages from splice.
> 
> Speaking of ef6a3c6311 ("mm: add replace_page_cache_page() function"),
> may I pathetically remind people that it's rather inefficient?
> 
> http://lkml.indiana.edu/hypermail/linux/kernel/1109.1/00375.html
> 

IIRC, people says inefficient because it uses memcg codes for page-migration
for fixing up accounting. Now, We added replace-page-cache for memcg in
memcg-add-mem_cgroup_replace_page_cache-to-fix-lru-issue.patch

So, I think the problem originally mentioned is fixed.

I'll reconsinder LRU handling optimization after things seems to be good.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
