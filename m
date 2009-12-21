Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 86F0A6B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 02:03:51 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBL73m9V023350
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 21 Dec 2009 16:03:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4677E45DE53
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:03:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 169E945DE50
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:03:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D528C1DB8037
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:03:47 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A6861DB803E
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:03:47 +0900 (JST)
Date: Mon, 21 Dec 2009 16:00:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 3/8] memcg: add interface to move charge at task
 migration
Message-Id: <20091221160021.a593fa8c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091221143346.7cbe44fa.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143346.7cbe44fa.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 14:33:46 +0900
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
> Changelog: 2009/12/14
> - Add TODO section to meory.txt.
> Changelog: 2009/12/04
> - change the term "recharge" to "move_charge".
> - update document.
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
