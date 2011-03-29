Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B678F8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 21:06:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AB6BE3EE081
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:06:41 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D04545DE4D
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:06:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7421B45DE4E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:06:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 67DC21DB8043
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:06:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 31B041DB803E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:06:41 +0900 (JST)
Date: Tue, 29 Mar 2011 10:00:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V2 1/2] count the soft_limit reclaim in global
 background reclaim
Message-Id: <20110329100013.63134160.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1301356270-26859-2-git-send-email-yinghan@google.com>
References: <1301356270-26859-1-git-send-email-yinghan@google.com>
	<1301356270-26859-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, 28 Mar 2011 16:51:09 -0700
Ying Han <yinghan@google.com> wrote:

> In the global background reclaim, we do soft reclaim before scanning the
> per-zone LRU. However, the return value is ignored.
> 
> We would like to skip shrink_zone() if soft_limit reclaim does enough work.
> Also, we need to make the memory pressure balanced across per-memcg zones,
> like the logic vm-core. This patch is the first step where we start with
> counting the nr_scanned and nr_reclaimed from soft_limit reclaim into the
> global scan_control.
> 
> Change log v2...v1:
> 1. Not skipping the shrink_zone() but instead count the nr_scanned and
> nr_reclaimed in the global scan_control.
> 2. Removed the stats into the next patch.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

seems better.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
