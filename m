Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AD5126B004D
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 02:35:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n626bRfb006695
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 2 Jul 2009 15:37:27 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F93045DE57
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 15:37:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D2B945DE4F
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 15:37:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F4221DB8040
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 15:37:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AE8651DB803B
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 15:37:26 +0900 (JST)
Date: Thu, 2 Jul 2009 15:35:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix cgroup rmdir hang v4
Message-Id: <20090702153545.15d313d6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090702063002.GO11273@balbir.in.ibm.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090701104747.afdcc6c7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090702063002.GO11273@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Jul 2009 12:00:05 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-01 10:47:47]:

> > -static void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
> > +static void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
> 
> Should the function explictly mention rmdir?
For now, yes. this is only for rmdir.

> Also something like
> release_rmdir should be called release_and_wakeup to make the action
> clearer.
> 
Hm, I don't think this name is too bad. Comment is enough and if we have to
change the behavior of cgroup-internal work, we have to rename this again.
This name is not too much explaining but showing enough information.


> Looks good to me otherwise and clean.
> 
Thank you.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
