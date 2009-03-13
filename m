Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 085DE6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 01:22:35 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D5MXY3025121
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Mar 2009 14:22:33 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 75AD345DE51
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 14:22:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AF1245DE50
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 14:22:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 31C87E18002
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 14:22:33 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C2C5C1DB8048
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 14:22:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] Memory controller soft limit organize cgroups (v5)
In-Reply-To: <20090313050433.GE16897@balbir.in.ibm.com>
References: <20090313094537.43D6.A69D9226@jp.fujitsu.com> <20090313050433.GE16897@balbir.in.ibm.com>
Message-Id: <20090313141251.AF44.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Mar 2009 14:22:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > >  /*
> > > + * Cgroups above their limits are maintained in a RB-Tree, independent of
> > > + * their hierarchy representation
> > > + */
> > > +
> > > +static struct rb_root mem_cgroup_soft_limit_tree;
> > > +static DEFINE_SPINLOCK(memcg_soft_limit_tree_lock);
> > 
> > I have objection to this.
> > Please don't use global spin lock.
> 
> We need a global data structure, per node, per zone is no good, since
> the limits (soft limit in this case) is for the entire cgroup.

this smell the data structure is wrong.

rb-tree soring is one of efficient reclaiming technique.
but global lock bust due to this patch's good side.

if its updating is really rare, rcu is better?
or couldn't you select another data structure?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
