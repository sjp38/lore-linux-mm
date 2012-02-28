Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id A9DF36B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:15:05 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 354D63EE0AE
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:15:04 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 167AE45DE55
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:15:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E932A45DE51
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:15:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D96921DB8040
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:15:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E6351DB802F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:15:03 +0900 (JST)
Date: Tue, 28 Feb 2012 09:13:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 03/21] memcg: fix page_referencies cgroup filter on
 global reclaim
Message-Id: <20120228091337.7d227a0e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135151.12988.37646.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135151.12988.37646.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:51:51 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Global memory reclaimer shouldn't skip any page referencies.
> 
> This patch pass sc->target_mem_cgroup into page_referenced().
> On global memory reclaim it always NULL, so we will account all.
> Cgroup reclaimer will account only referencies from target cgroup and its childs.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

seems nice to me.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
