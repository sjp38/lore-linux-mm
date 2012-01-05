Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id CD7CB6B005C
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 01:03:08 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 670A53EE081
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:03:07 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4384645DE54
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:03:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F84B45DE5A
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:03:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AFDE1DB8054
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:03:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B4A481DB804C
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:03:06 +0900 (JST)
Date: Thu, 5 Jan 2012 15:01:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] memcg: fix mem_cgroup_print_bad_page
Message-Id: <20120105150150.436dfce8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112281623400.8257@eggly.anvils>
References: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
	<alpine.LSU.2.00.1112281623400.8257@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Wed, 28 Dec 2011 16:26:02 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> If DEBUG_VM, mem_cgroup_print_bad_page() is called whenever bad_page()
> shows a "Bad page state" message, removes page from circulation, adds a
> taint and continues.  This is at a very low level, often when a spinlock
> is held (sometimes when page table lock is held, for example).
> 
> We want to recover from this badness, not make it worse: we must not
> kmalloc memory here, we must not do a cgroup path lookup via dubious
> pointers.  No doubt that code was useful to debug a particular case
> at one time, and may be again, but take it out of the mainline kernel.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
