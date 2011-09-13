Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AAC8D900161
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 06:08:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 06F723EE0C2
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:08:39 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E168F45DEAD
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:08:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA67F45DEA6
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:08:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA7491DB803F
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:08:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B1581DB803B
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:08:38 +0900 (JST)
Date: Tue, 13 Sep 2011 19:07:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 02/11] mm: vmscan: distinguish global reclaim from
 global LRU scanning
Message-Id: <20110913190749.c56d3f90.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315825048-3437-3-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
	<1315825048-3437-3-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Sep 2011 12:57:19 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> The traditional zone reclaim code is scanning the per-zone LRU lists
> during direct reclaim and kswapd, and the per-zone per-memory cgroup
> LRU lists when reclaiming on behalf of a memory cgroup limit.
> 
> Subsequent patches will convert the traditional reclaim code to
> reclaim exclusively from the per-memory cgroup LRU lists.  As a
> result, using the predicate for which LRU list is scanned will no
> longer be appropriate to tell global reclaim from limit reclaim.
> 
> This patch adds a global_reclaim() predicate to tell direct/kswapd
> reclaim from memory cgroup limit reclaim and substitutes it in all
> places where currently scanning_global_lru() is used for that.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
