Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 716C6900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 06:24:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 304623EE0C2
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:24:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 12BBD45DE53
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:24:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFDA545DE4F
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:24:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DDEC41DB8041
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:24:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A572F1DB803B
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:24:08 +0900 (JST)
Date: Tue, 13 Sep 2011 19:23:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 03/11] mm: vmscan: distinguish between memcg triggering
 reclaim and memcg being scanned
Message-Id: <20110913192325.9f675d8d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315825048-3437-4-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
	<1315825048-3437-4-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Sep 2011 12:57:20 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> Memory cgroup hierarchies are currently handled completely outside of
> the traditional reclaim code, which is invoked with a single memory
> cgroup as an argument for the whole call stack.
> 
> Subsequent patches will switch this code to do hierarchical reclaim,
> so there needs to be a distinction between a) the memory cgroup that
> is triggering reclaim due to hitting its limit and b) the memory
> cgroup that is being scanned as a child of a).
> 
> This patch introduces a struct mem_cgroup_zone that contains the
> combination of the memory cgroup and the zone being scanned, which is
> then passed down the stack instead of the zone argument.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
