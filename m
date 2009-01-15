Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 15CC56B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 00:28:32 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F5SUA9000568
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 14:28:31 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AA79945DE52
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 14:28:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B39945DE4F
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 14:28:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 741681DB803A
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 14:28:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 30EBC1DB803B
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 14:28:30 +0900 (JST)
Date: Thu, 15 Jan 2009 14:27:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
 obsolete
Message-Id: <20090115142725.c3ee5dc4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115051717.GH21516@balbir.in.ibm.com>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
	<20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
	<20090114135539.GA21516@balbir.in.ibm.com>
	<20090115122416.e15d88a7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115041750.GE21516@balbir.in.ibm.com>
	<20090115135223.1789e639.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115051717.GH21516@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 10:47:17 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-15 13:52:23]:

> > I think rmdir() should succeed everywhen "there are no tasks and children".
> > And that can be done.
> >
> 
> All I am saying is that let rmdir() fail if there are tasks or
> children, which I suspect cgroup takes care of. The second thing to do would
> be to add a mem_cgroup_get_hierarchical() and _put_hierarchical() API's so
> that we can get references all the way up to the parents. My concern
> is that not calling res_counter_uncharge() can lead to dangling
> references and bad behaviour.
>  
> > With Paul's suggestion, I'll add wait_queue for rmdir of cgroup.
> > 
> 
> That might be a good idea and also a good idea to maintain the
> hierarchy (since we will walk up when we do uncharge) until we know
> that css reference count is down to 0.
> 
It seems Nishimura started his work in that direction. (see other mail.)
Let's wait a bit.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
