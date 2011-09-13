Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 47E77900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 06:42:41 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 69DC03EE0B6
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:42:38 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FA2C45DE58
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:42:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 354CF45DE59
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:42:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2739D1DB8051
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:42:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E6F95E08001
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:42:37 +0900 (JST)
Date: Tue, 13 Sep 2011 19:41:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 08/11] mm: vmscan: convert global reclaim to per-memcg
 LRU lists
Message-Id: <20110913194150.ce66b655.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315825048-3437-9-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
	<1315825048-3437-9-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Sep 2011 12:57:25 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> The global per-zone LRU lists are about to go away on memcg-enabled
> kernels, global reclaim must be able to find its pages on the
> per-memcg LRU lists.
> 
> Since the LRU pages of a zone are distributed over all existing memory
> cgroups, a scan target for a zone is complete when all memory cgroups
> are scanned for their proportional share of a zone's memory.
> 
> The forced scanning of small scan targets from kswapd is limited to
> zones marked unreclaimable, otherwise kswapd can quickly overreclaim
> by force-scanning the LRU lists of multiple memory cgroups.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>


Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
