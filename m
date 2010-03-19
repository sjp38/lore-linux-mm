Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9F93E6B008C
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 21:27:23 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J1RKRh005009
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Mar 2010 10:27:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FCA045DE52
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 10:27:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA9C945DE4E
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 10:27:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A9AD6E08001
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 10:27:19 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 592B11DB8037
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 10:27:16 +0900 (JST)
Date: Fri, 19 Mar 2010 10:23:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-Id: <20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100318162855.GG18054@balbir.in.ibm.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100317115855.GS18054@balbir.in.ibm.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318041944.GA18054@balbir.in.ibm.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Mar 2010 21:58:55 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 13:35:27]:
 
> > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indpendent from
> > mem_cgroup_update_file_mapped(). The look may be messy but it's not your
> > fault. But please write "why add new function" to patch description.
> > 
> > I'm sorry for wasting your time.
> 
> Do we need to go down this route? We could check the stat and do the
> correct thing. In case of FILE_MAPPED, always grab page_cgroup_lock
> and for others potentially look at trylock. It is OK for different
> stats to be protected via different locks.
> 

I _don't_ want to see a mixture of spinlock and trylock in a function.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
