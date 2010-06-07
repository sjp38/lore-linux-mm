Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4C7256B01AF
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 02:06:43 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5766e02027946
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 7 Jun 2010 15:06:40 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EDD9145DE6E
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 15:06:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C8CF045DE79
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 15:06:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A40581DB8042
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 15:06:39 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 236201DB8040
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 15:06:39 +0900 (JST)
Date: Mon, 7 Jun 2010 15:02:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [cleanup][PATCH -mmotm 1/2] memcg: remove redundant codes
Message-Id: <20100607150207.6971b8b9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100607145239.cb5cb917.nishimura@mxp.nes.nec.co.jp>
References: <20100607145239.cb5cb917.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jun 2010 14:52:39 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> These patches are based on mmotm-2010-06-03-16-36 + some already merged patches
> for memcg.
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> - try_get_mem_cgroup_from_mm() calls rcu_read_lock/unlock by itself, so we
>   don't have to call them in task_in_mem_cgroup().
> - *mz is not used in __mem_cgroup_uncharge_common().
> - we don't have to call lookup_page_cgroup() in mem_cgroup_end_migration()
>   after we've cleared PCG_MIGRATION of @oldpage.
> - remove empty comment.
> - remove redundant empty line in mem_cgroup_cache_charge().
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
