Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id ECDCB6B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:39:41 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7E8FD3EE0AE
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:39:40 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 654EC45DEB2
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:39:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4516C45DE9E
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:39:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 339091DB8040
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:39:40 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DC70B1DB803B
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:39:39 +0900 (JST)
Date: Tue, 28 Feb 2012 09:38:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 09/21] mm: add lruvec->reclaim_stat
Message-Id: <20120228093811.77b5ac09.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135224.12988.54332.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135224.12988.54332.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:52:24 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Merge memcg and non-memcg reclaim stat. We need to update only one.
> Move zone->reclaimer_stat and mem_cgroup_per_zone->reclaimer_stat to struct lruvec.
> 
> struct lruvec will become operating unit for recalimer logic,
> thus this is perfect place for these counters.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

I like this.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
