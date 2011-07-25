Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7886B00EE
	for <linux-mm@kvack.org>; Sun, 24 Jul 2011 21:24:27 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B4E923EE0C0
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 10:24:23 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 945ED45DE5B
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 10:24:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D10145DE56
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 10:24:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F3AE1DB8052
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 10:24:23 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B2D71DB8045
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 10:24:23 +0900 (JST)
Date: Mon, 25 Jul 2011 10:16:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] memcg: do not try to drain per-cpu caches without
 pages
Message-Id: <20110725101657.21f85bf0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <2f17df54db6661c39a05669d08a9e6257435b898.1311338634.git.mhocko@suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
	<2f17df54db6661c39a05669d08a9e6257435b898.1311338634.git.mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Thu, 21 Jul 2011 09:38:00 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> drain_all_stock_async tries to optimize a work to be done on the work
> queue by excluding any work for the current CPU because it assumes that
> the context we are called from already tried to charge from that cache
> and it's failed so it must be empty already.
> While the assumption is correct we can optimize it even more by checking
> the current number of pages in the cache. This will also reduce a work
> on other CPUs with an empty stock.
> For the current CPU we can simply call drain_local_stock rather than
> deferring it to the work queue.
> 
> [KAMEZAWA Hiroyuki - use drain_local_stock for current CPU optimization]
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
