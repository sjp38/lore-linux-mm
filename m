Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2F09260021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 01:58:42 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB46wcq0028606
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Dec 2009 15:58:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A8AE45DE3A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:58:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2228245DE54
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:58:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E002DE18009
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:58:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 21E70E1800B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:58:37 +0900 (JST)
Date: Fri, 4 Dec 2009 15:55:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 2/7] memcg: add interface to move charge at task
 migration
Message-Id: <20091204155543.1982efca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091204144836.41401c14.nishimura@mxp.nes.nec.co.jp>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
	<20091204144836.41401c14.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009 14:48:36 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> In current memcg, charges associated with a task aren't moved to the new cgroup
> at task migration. Some users feel this behavior to be strange.
> These patches are for this feature, that is, for charging to the new cgroup
> and, of course, uncharging from the old cgroup at task migration.
> 
> This patch adds "memory.move_charge_at_immigrate" file, which is a flag file to
> determine whether charges should be moved to the new cgroup at task migration or
> not and what type of charges should be moved. This patch also adds read and
> write handlers of the file.
> 
> This patch also adds no-op handlers for this feature. These handlers will be
> implemented in later patches. And you cannot write any values other than 0
> to move_charge_at_immigrate yet.
> 
> Changelog: 2009/12/04
> - change the term "recharge" to "move_charge".
> - update memory.txt.
> Changelog: 2009/11/19
> - consolidate changes in Documentation/cgroup/memory.txt, which were made in
>   other patches separately.
> - handle recharge_at_immigrate as bitmask(as I did in first version).
> - use mm->owner instead of thread_group_leader().
> Changelog: 2009/09/24
> - change the term "migration" to "recharge".
> - handle the flag as bool not bitmask to make codes simple.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
