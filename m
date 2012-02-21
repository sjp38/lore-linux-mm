Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 2FAD06B004D
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 03:07:08 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C19043EE0BD
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:07:06 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A64D845DEB2
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:07:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D61045DE9E
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:07:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F4AB1DB803F
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:07:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 258CE1DB8047
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:07:06 +0900 (JST)
Date: Tue, 21 Feb 2012 17:05:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/10] mm/memcg: move reclaim_stat into lruvec
Message-Id: <20120221170538.84461d91.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202201528280.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
	<alpine.LSU.2.00.1202201528280.23274@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Feb 2012 15:29:37 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> With mem_cgroup_disabled() now explicit, it becomes clear that the
> zone_reclaim_stat structure actually belongs in lruvec, per-zone
> when memcg is disabled but per-memcg per-zone when it's enabled.
> 
> We can delete mem_cgroup_get_reclaim_stat(), and change
> update_page_reclaim_stat() to update just the one set of stats,
> the one which get_scan_count() will actually use.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Seems nice to me.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
