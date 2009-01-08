Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0DD536B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 06:00:50 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n08B0mA4015988
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 20:00:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C5B9F45DE61
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:00:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A3BC945DE57
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:00:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 84C691DB8044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:00:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B8781DB8040
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 20:00:47 +0900 (JST)
Message-ID: <37143.10.75.179.62.1231412446.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090108191445.cd860c37.nishimura@mxp.nes.nec.co.jp>
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
    <20090108191445.cd860c37.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 8 Jan 2009 20:00:46 +0900 (JST)
Subject: Re: [RFC][PATCH 2/4] memcg: fix error path of
     mem_cgroup_move_parent
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura said:
> There is a bug in error path of mem_cgroup_move_parent.
>
> Extra refcnt got from try_charge should be dropped, and usages incremented
> by try_charge should be decremented in both error paths:
>
>     A: failure at get_page_unless_zero
>     B: failure at isolate_lru_page
>
> This bug makes this parent directory unremovable.
>
> In case of A, rmdir doesn't return, because res.usage doesn't go
> down to 0 at mem_cgroup_force_empty even after all the pc in
> lru are removed.
> In case of B, rmdir fails and returns -EBUSY, because it has
> extra ref counts even after res.usage goes down to 0.
>
>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Thank you for catching.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
