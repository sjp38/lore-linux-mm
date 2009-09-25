Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2A0916B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 20:51:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8P0pO9Z011068
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 09:51:24 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C91845DE4E
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 09:51:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DAFA45DE4D
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 09:51:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 16FA71DB8037
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 09:51:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C80861DB803C
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 09:51:20 +0900 (JST)
Date: Fri, 25 Sep 2009 09:49:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/8] memcg: migrate charge of mapped page
Message-Id: <20090925094913.5ea3bd2e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090925092837.e3abe3b3.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924144808.6a0d5140.nishimura@mxp.nes.nec.co.jp>
	<20090924162226.5c703903.kamezawa.hiroyu@jp.fujitsu.com>
	<20090924170002.c7441b52.nishimura@mxp.nes.nec.co.jp>
	<20090925092837.e3abe3b3.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Sep 2009 09:28:37 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > > Hmm, I don't complain to this patch itself but cgroup_lock() will be the
> > > last wall to be overcomed for production use...
> > > 
> > > Can't we just prevent rmdir/mkdir on a hierarchy and move a task ?
> > > fork() etc..can be stopped by this and cpuset's code is not very good.
> > >  
> hmm, could you explan more why fork() can be stopped by cgroup_lock(or cgroup_mutex)?
> 

Sorry, I misunderstood cgroup_fork/clone.

Anyway, while doing migration, libcgroup's daemon cannot work for moving
a task to a group.

Thanks,
-Kame

> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
