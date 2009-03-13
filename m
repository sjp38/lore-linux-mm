Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 05BC46B0047
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 01:04:45 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2D52jeY027276
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:02:45 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D54vGh422128
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:04:57 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2D54dMZ024974
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:04:39 +1100
Date: Fri, 13 Mar 2009 10:34:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] Memory controller soft limit organize cgroups (v5)
Message-ID: <20090313050433.GE16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain> <20090312175625.17890.94795.sendpatchset@localhost.localdomain> <20090313094537.43D6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090313094537.43D6.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-13 09:47:31]:

> >  /*
> > + * Cgroups above their limits are maintained in a RB-Tree, independent of
> > + * their hierarchy representation
> > + */
> > +
> > +static struct rb_root mem_cgroup_soft_limit_tree;
> > +static DEFINE_SPINLOCK(memcg_soft_limit_tree_lock);
> 
> I have objection to this.
> Please don't use global spin lock.

We need a global data structure, per node, per zone is no good, since
the limits (soft limit in this case) is for the entire cgroup.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
