Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 786436B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 20:28:40 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1316C3EE081
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:28:39 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ECF4545DE58
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:28:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D404845DE56
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:28:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C319E1DB8049
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:28:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 79C0B1DB8048
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 10:28:38 +0900 (JST)
Date: Fri, 9 Mar 2012 10:27:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 2/7] mm/memcg: move reclaim_stat into lruvec
Message-Id: <20120309102707.0a32cf45.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120308180405.27621.97346.stgit@zurg>
References: <20120308175752.27621.54781.stgit@zurg>
	<20120308180405.27621.97346.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 08 Mar 2012 22:04:06 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> From: Hugh Dickins <hughd@google.com>
> 
> With mem_cgroup_disabled() now explicit, it becomes clear that the
> zone_reclaim_stat structure actually belongs in lruvec, per-zone
> when memcg is disabled but per-memcg per-zone when it's enabled.
> 
> We can delete mem_cgroup_get_reclaim_stat(), and change
> update_page_reclaim_stat() to update just the one set of stats,
> the one which get_scan_count() will actually use.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
