Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6FF696B0218
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 22:12:06 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3O2C2Qv010694
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 24 Apr 2010 11:12:03 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A1F9A45DE6F
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:12:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E49D45DE6E
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:12:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 558821DB803B
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:12:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 04CC91DB8037
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:11:59 +0900 (JST)
Date: Sat, 24 Apr 2010 11:08:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg rcu lock fix v3
Message-Id: <20100424110805.17c7f86e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100423193406.GD2589@linux.vnet.ibm.com>
References: <4BD10D59.9090504@cn.fujitsu.com>
	<20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
	<4BD118E2.7080307@cn.fujitsu.com>
	<4BD11A24.2070500@cn.fujitsu.com>
	<20100423125814.01e95bce.kamezawa.hiroyu@jp.fujitsu.com>
	<20100423130349.f320d0be.kamezawa.hiroyu@jp.fujitsu.com>
	<20100423193406.GD2589@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 12:34:06 -0700
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> On Fri, Apr 23, 2010 at 01:03:49PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Fri, 23 Apr 2010 12:58:14 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Fri, 23 Apr 2010 11:55:16 +0800
> > > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > 
> > > > Li Zefan wrote:
> > > > > KAMEZAWA Hiroyuki wrote:
> > > > >> On Fri, 23 Apr 2010 11:00:41 +0800
> > > > >> Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > > >>
> > > > >>> with CONFIG_PROVE_RCU=y, I saw this warning, it's because
> > > > >>> css_id() is not under rcu_read_lock().
> > > > >>>
> > > > >> Ok. Thank you for reporting.
> > > > >> This is ok ? 
> > > > > 
> > > > > Yes, and I did some more simple tests on memcg, no more warning
> > > > > showed up.
> > > > > 
> > > > 
> > > > oops, after trigging oom, I saw 2 more warnings:
> > > > 
> > > 
> > > Thank you for good testing.
> > v3 here...sorry too rapid posting...
> > 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I have queued this, thank you all!
> 
> However, memcg_oom_wake_function() does not yet exist in the tree
> I am using, and is_target_pte_for_mc() has changed.  I omitted the
> hunk for memcg_oom_wake_function() and edited the hunk for
> is_target_pte_for_mc().
> 
Ok, memcg_oom_wake_function is for -mm. I'll prepare another patch for -mm.


> I have queued this for others' testing, but if you would rather carry
> this patch up the memcg path, please let me know and I will drop it.
> 
I think it's ok to be fixed by your tree. I'll look at memcg later and
fix remaining things.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
