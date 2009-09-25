Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA9836B004F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 20:38:36 -0400 (EDT)
Date: Fri, 25 Sep 2009 09:28:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 5/8] memcg: migrate charge of mapped page
Message-Id: <20090925092837.e3abe3b3.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090924170002.c7441b52.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924144808.6a0d5140.nishimura@mxp.nes.nec.co.jp>
	<20090924162226.5c703903.kamezawa.hiroyu@jp.fujitsu.com>
	<20090924170002.c7441b52.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > Hmm, I don't complain to this patch itself but cgroup_lock() will be the
> > last wall to be overcomed for production use...
> > 
> > Can't we just prevent rmdir/mkdir on a hierarchy and move a task ?
> > fork() etc..can be stopped by this and cpuset's code is not very good.
> >  
hmm, could you explan more why fork() can be stopped by cgroup_lock(or cgroup_mutex)?

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
