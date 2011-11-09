Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D129A6B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 19:06:31 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4A1FD3EE081
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 09:06:28 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C8EF45DEA6
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 09:06:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1755745DE7E
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 09:06:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F33551DB803F
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 09:06:27 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B32D81DB803C
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 09:06:27 +0900 (JST)
Date: Wed, 9 Nov 2011 09:05:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 00/10] memcg naturalization -rc5
Message-Id: <20111109090520.e9bf6a4f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
References: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue,  8 Nov 2011 22:23:18 +0100
Johannes Weiner <jweiner@redhat.com> wrote:

> This is version 5 of the memcg naturalization patches.
> 
> They enable traditional page reclaim to find pages from the per-memcg
> LRU lists, thereby getting rid of the double-LRU scheme (per global
> zone in addition to per memcg-zone) and the required extra list head
> per each page in the system.
> 
> The only change from version 4 is using the name `memcg' instead of
> `mem' for memcg pointers in code added in the series.
> 
> This series is based on v3.2-rc1.
> 
> memcg users and distributions are waiting for this because of the
> memory savings.  The changes for regular users that do not create
> memcgs in addition to the root memcg are minimal, and even smaller for
> users that disable the memcg feature at compile time.  Lastly, ongoing
> memcg development, like the breaking up of zone->lru_lock, fixing the
> soft limit implementation/memory guarantees and per-memcg reclaim
> statistics, is already based on this.
> 
> Thanks!

Thank you !.

It seems this series is in -mm now and all memcg patches should be based
on this work.

Note: Everyone, please CC cgroups@vger.kernel.org about cgroup related
changes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
