Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 55F8B8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 00:45:44 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 70C383EE0C2
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:45:40 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5983F45DE51
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:45:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4464845DE4E
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:45:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 37AB11DB802F
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:45:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 044E21DB803F
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 14:45:40 +0900 (JST)
Date: Mon, 7 Mar 2011 14:39:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 30432] New: rmdir on cgroup can cause hang
 tasks
Message-Id: <20110307143919.e4606054.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110307135803.a7d718ce.kamezawa.hiroyu@jp.fujitsu.com>
References: <bug-30432-10286@https.bugzilla.kernel.org/>
	<20110304000355.4f68bab1.akpm@linux-foundation.org>
	<20110304172815.9d9e3672.kamezawa.hiroyu@jp.fujitsu.com>
	<20110304180157.133fdfd1.kamezawa.hiroyu@jp.fujitsu.com>
	<20110307135803.a7d718ce.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Poelzleithner <poelzi@poelzi.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, containers@lists.osdl.org, Paul Menage <menage@google.com>

On Mon, 7 Mar 2011 13:58:03 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 4 Mar 2011 18:01:57 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Fri, 4 Mar 2011 17:28:15 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > This seems....
> > > ==
> > > static void mem_cgroup_start_move(struct mem_cgroup *mem)
> > > {
> > > .....
> > > 	put_online_cpus();
> > > 
> > >         synchronize_rcu();   <---------(*)
> > > }
> > > ==
> > > 
> > 
> > But this may scan LRU of memcg forever and SysRq+T just shows
> > above stack.
> > 
> > I'll check a tree before THP and force_empty again
> 
> Hmm, one more conern is what kind of file system is used ?
> 
> Can I see 
>  - /prco/mounts
> and your .config ?
> 
> If you use FUSE, could you try this ?
> 
> I'll prepare one for mmotm.
> 

Sorry, this version may contain hung-up bug...
I'll start from fix for mmotm and backport it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
