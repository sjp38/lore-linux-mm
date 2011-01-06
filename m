Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B1CAE6B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 21:01:31 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1CBBE3EE0B5
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 11:01:28 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 02F4A45DE54
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 11:01:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CDE8B45DE51
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 11:01:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BB0BC1DB803A
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 11:01:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8472AEF8003
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 11:01:27 +0900 (JST)
Date: Thu, 6 Jan 2011 10:55:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix memory migration of shmem swapcache
Message-Id: <20110106105539.e55026d4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110106100923.24b1dd12.nishimura@mxp.nes.nec.co.jp>
References: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
	<20110105115840.GD4654@cmpxchg.org>
	<20110106100923.24b1dd12.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Jan 2011 10:09:23 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> In current implimentation, mem_cgroup_end_migration() decides whether the page
> migration has succeeded or not by checking "oldpage->mapping".
> 
> But if we are tring to migrate a shmem swapcache, the page->mapping of it is
> NULL from the begining, so the check would be invalid.
> As a result, mem_cgroup_end_migration() assumes the migration has succeeded
> even if it's not, so "newpage" would be freed while it's not uncharged.
> 
> This patch fixes it by passing mem_cgroup_end_migration() the result of the
> page migration.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
