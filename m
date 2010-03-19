Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C176D6B0098
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 23:04:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J34Y60007928
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Mar 2010 12:04:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DF7C745DE4F
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 12:04:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EFC4645DE4D
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 12:04:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CBDB51DB8055
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 12:04:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B2E241DB8047
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 12:04:31 +0900 (JST)
Date: Fri, 19 Mar 2010 12:00:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-Id: <20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100319024039.GH18054@balbir.in.ibm.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100317115855.GS18054@balbir.in.ibm.com>
	<20100318085411.834e1e46.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318041944.GA18054@balbir.in.ibm.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrea Righi <arighi@develer.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Mar 2010 08:10:39 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-19 10:23:32]:
> 
> > On Thu, 18 Mar 2010 21:58:55 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-18 13:35:27]:
> > 
> > > > Then, no probelm. It's ok to add mem_cgroup_udpate_stat() indpendent from
> > > > mem_cgroup_update_file_mapped(). The look may be messy but it's not your
> > > > fault. But please write "why add new function" to patch description.
> > > > 
> > > > I'm sorry for wasting your time.
> > > 
> > > Do we need to go down this route? We could check the stat and do the
> > > correct thing. In case of FILE_MAPPED, always grab page_cgroup_lock
> > > and for others potentially look at trylock. It is OK for different
> > > stats to be protected via different locks.
> > > 
> > 
> > I _don't_ want to see a mixture of spinlock and trylock in a function.
> >
> 
> A well documented well written function can help. The other thing is to
> of-course solve this correctly by introducing different locking around
> the statistics. Are you suggesting the later?
> 

No. As I wrote.
	- don't modify codes around FILE_MAPPED in this series.
	- add a new functions for new statistics
Then,
	- think about clean up later, after we confirm all things work as expected.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
