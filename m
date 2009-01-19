Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 642386B00A2
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 02:16:16 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0J7GEwc011722
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 19 Jan 2009 16:16:14 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E474D45DD72
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 16:16:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C465145DD6F
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 16:16:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D3BA1DB8042
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 16:16:13 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56CB71DB8040
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 16:16:13 +0900 (JST)
Date: Mon, 19 Jan 2009 16:15:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: update document to mention swapoff should be
 test.
Message-Id: <20090119161508.f8b9d342.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090119071220.GE6039@balbir.in.ibm.com>
References: <20090119155748.acc60988.kamezawa.hiroyu@jp.fujitsu.com>
	<20090119071220.GE6039@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jan 2009 12:42:20 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-19 15:57:48]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Considering recently found problem:
> >  memcg-fix-refcnt-handling-at-swapoff.patch
> > 
> > It's better to mention about swapoff behavior in memcg_test document.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  Documentation/cgroups/memcg_test.txt |   24 ++++++++++++++++++++++--
> >  1 file changed, 22 insertions(+), 2 deletions(-)
> > 
> > Index: mmotm-2.6.29-Jan16/Documentation/cgroups/memcg_test.txt
> > ===================================================================
> > --- mmotm-2.6.29-Jan16.orig/Documentation/cgroups/memcg_test.txt
> > +++ mmotm-2.6.29-Jan16/Documentation/cgroups/memcg_test.txt
> > @@ -1,6 +1,6 @@
> >  Memory Resource Controller(Memcg)  Implementation Memo.
> > -Last Updated: 2008/12/15
> > -Base Kernel Version: based on 2.6.28-rc8-mm.
> > +Last Updated: 2009/1/19
> > +Base Kernel Version: based on 2.6.29-rc2.
> > 
> >  Because VM is getting complex (one of reasons is memcg...), memcg's behavior
> >  is complex. This is a document for memcg's internal behavior.
> > @@ -340,3 +340,23 @@ Under below explanation, we assume CONFI
> >  	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
> > 
> >  	and do task move, mkdir, rmdir etc...under this.
> > +
> > + 9.7 swapoff.
> > +	Besides management of swap is one of complicated parts of memcg,
> > +	call path of swap-in at swapoff is not same as usual swap-in path..
> > +	It's worth to be tested explicitly.
> > +
> > +	For example, test like following is good.
> > +	(Shell-A)
> > +	# mount -t cgroup none /cgroup -t memory
> > +	# mkdir /cgroup/test
> > +	# echo 40M > /cgroup/test/memory.limit_in_bytes
> > +	# echo 0 > /cgroup/test/tasks
> 
> 0? shouldn't this be pid? Potentially echo $$
> 

0 is handled as $$ in cgroup/tasks file.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
