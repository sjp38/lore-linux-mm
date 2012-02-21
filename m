Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 3CE0F6B004D
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 03:09:35 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BED523EE081
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:09:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E82045DE57
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:09:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8444D45DE51
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:09:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 77B53E08003
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:09:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EB051DB803E
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:09:33 +0900 (JST)
Date: Tue, 21 Feb 2012 17:08:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/10] mm/memcg: add zone pointer into lruvec
Message-Id: <20120221170807.a5b961db.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202201529450.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
	<alpine.LSU.2.00.1202201529450.23274@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Feb 2012 15:30:45 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> The lruvec is looking rather useful: if we just add a zone pointer
> into the lruvec, then we can pass the lruvec pointer around and save
> some superfluous arguments and recomputations in various places.
> 
> Just occasionally we do want mem_cgroup_from_lruvec() to get back from
> lruvec to memcg; but then we can remove all uses of vmscan.c's private
> mem_cgroup_zone *mz, passing the lruvec pointer instead.
> 
> And while we're there, get_scan_count() can call vmscan_swappiness()
> once, instead of twice in a row.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---

I like this cleanup

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
