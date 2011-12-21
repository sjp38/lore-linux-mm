Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 545BC6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 19:03:18 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7B5C63EE0C0
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:03:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F2772AEA83
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:03:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 45AC0227D25
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:03:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 36EFA1DB8040
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:03:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E53451DB802F
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:03:15 +0900 (JST)
Date: Wed, 21 Dec 2011 09:01:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] memcg: simplify page cache charging.
Message-Id: <20111221090158.64521b11.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111220135817.5ba7ab05.akpm@linux-foundation.org>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
	<20111214164922.05fb4afe.kamezawa.hiroyu@jp.fujitsu.com>
	<20111216142814.dbb77209.akpm@linux-foundation.org>
	<20111219090122.66024659.kamezawa.hiroyu@jp.fujitsu.com>
	<20111220135817.5ba7ab05.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Tue, 20 Dec 2011 13:58:17 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 19 Dec 2011 09:01:22 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Fri, 16 Dec 2011 14:28:14 -0800
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > On Wed, 14 Dec 2011 16:49:22 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > Because of commit ef6a3c6311, FUSE uses replace_page_cache() instead
> > > > of add_to_page_cache(). Then, mem_cgroup_cache_charge() is not
> > > > called against FUSE's pages from splice.
> > > 
> > > Speaking of ef6a3c6311 ("mm: add replace_page_cache_page() function"),
> > > may I pathetically remind people that it's rather inefficient?
> > > 
> > > http://lkml.indiana.edu/hypermail/linux/kernel/1109.1/00375.html
> > > 
> > 
> > IIRC, people says inefficient because it uses memcg codes for page-migration
> > for fixing up accounting. Now, We added replace-page-cache for memcg in
> > memcg-add-mem_cgroup_replace_page_cache-to-fix-lru-issue.patch
> > 
> > So, I think the problem originally mentioned is fixed.
> > 
> 
> No, the inefficiency in replace_page_cache_page() is still there.  Two
> identical walks down the radix tree, a pointless decrement then
> increment of mapping->nrpages, two writes to page->mapping, an often
> pointless decrement then increment of NR_FILE_PAGES, and probably other things.
> 

Hmm, then, replace_page_cache_page() itself has some problem.
I'll look into that.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
