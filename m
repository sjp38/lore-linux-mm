Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D2717900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 06:32:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E43F43EE0BC
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:32:01 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BE5AA45DE8A
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:32:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A214E45DE7A
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:32:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 91ABA1DB8049
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:32:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F4641DB8043
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 19:32:01 +0900 (JST)
Date: Tue, 13 Sep 2011 19:31:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 05/11] mm: move memcg hierarchy reclaim to generic
 reclaim code
Message-Id: <20110913193115.6098c87a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315825048-3437-6-git-send-email-jweiner@redhat.com>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
	<1315825048-3437-6-git-send-email-jweiner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Sep 2011 12:57:22 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> Memory cgroup limit reclaim and traditional global pressure reclaim
> will soon share the same code to reclaim from a hierarchical tree of
> memory cgroups.
> 
> In preparation of this, move the two right next to each other in
> shrink_zone().
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

ok, this will be good direction.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
