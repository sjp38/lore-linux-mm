Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 498FD8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 03:19:20 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 174733EE0BD
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 16:19:15 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EC12045DE6D
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 16:19:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D020245DE61
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 16:19:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF6FC1DB802C
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 16:19:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BD731DB803E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 16:19:14 +0900 (JST)
Date: Tue, 29 Mar 2011 16:12:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3 2/2] add stats to monitor soft_limit reclaim
Message-Id: <20110329161233.7dc7e717.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1301378186-23199-3-git-send-email-yinghan@google.com>
References: <1301378186-23199-1-git-send-email-yinghan@google.com>
	<1301378186-23199-3-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, 28 Mar 2011 22:56:26 -0700
Ying Han <yinghan@google.com> wrote:

> The stat is added:
> 
> /dev/cgroup/*/memory.stat
> soft_steal:        - # of pages reclaimed from soft_limit hierarchical reclaim
> soft_scan:         - # of pages scanned from soft_limit hierarchical reclaim
> total_soft_steal:  - # sum of all children's "soft_steal"
> total_soft_scan:   - # sum of all children's "soft_scan"
> 
> Change v3..v2
> 1. add the soft_scan stat
> 2. count the soft_scan and soft_steal within hierarchical reclaim
> 3. removed the unnecessary export in memcontrol.h
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
