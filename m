Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 88A83900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 03:00:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6F75F3EE081
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:00:01 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5889E45DE7A
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:00:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F4C545DE68
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:00:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3229A1DB8038
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:00:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F07FF1DB802C
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:00:00 +0900 (JST)
Date: Thu, 18 Aug 2011 15:52:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
Message-Id: <20110818155234.e8afee9b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1313650253-21794-1-git-send-email-gthelen@google.com>
References: <1313650253-21794-1-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Wed, 17 Aug 2011 23:50:53 -0700
Greg Thelen <gthelen@google.com> wrote:

> Both mem_cgroup_charge_statistics() and mem_cgroup_move_account() were
> unnecessarily disabling preemption when adjusting per-cpu counters:
>     preempt_disable()
>     __this_cpu_xxx()
>     __this_cpu_yyy()
>     preempt_enable()
> 
> This change does not disable preemption and thus CPU switch is possible
> within these routines.  This does not cause a problem because the total
> of all cpu counters is summed when reporting stats.  Now both
> mem_cgroup_charge_statistics() and mem_cgroup_move_account() look like:
>     this_cpu_xxx()
>     this_cpu_yyy()
> 
> Reported-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
