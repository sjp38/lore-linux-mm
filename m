Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 0D02A6B00E7
	for <linux-mm@kvack.org>; Mon, 14 May 2012 06:36:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8A7093EE0C7
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:36:30 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F7FC45DE55
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:36:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5689B45DE52
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:36:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4801C1DB803E
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:36:30 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 008911DB803B
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:36:30 +0900 (JST)
Message-ID: <4FB0DFBE.2000106@jp.fujitsu.com>
Date: Mon, 14 May 2012 19:34:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/memcg: get_lru_size not get_lruvec_size
References: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils> <alpine.LSU.2.00.1205132158470.6148@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1205132158470.6148@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/05/14 14:00), Hugh Dickins wrote:

> Konstantin just introduced mem_cgroup_get_lruvec_size() and
> get_lruvec_size(), I'm about to add mem_cgroup_update_lru_size():
> but we're dealing with the same thing, lru_size[lru].  We ought to
> agree on the naming, and I do think lru_size is the more correct:
> so rename his ones to get_lru_size().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
