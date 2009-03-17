Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A7376B0047
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 02:02:24 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2H62L2F028992
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Mar 2009 15:02:21 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 40AB945DE51
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:02:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 063A645DE50
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:02:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC2A31DB8037
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:02:20 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 761D81DB803B
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:02:20 +0900 (JST)
Date: Tue, 17 Mar 2009 15:00:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v6)
Message-Id: <20090317150058.5b8a96b9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090317055506.GM16897@balbir.in.ibm.com>
References: <20090316091024.GX16897@balbir.in.ibm.com>
	<2217159d612e4e4d3fcbd50354e53f5b.squirrel@webmail-b.css.fujitsu.com>
	<20090316113853.GA16897@balbir.in.ibm.com>
	<969730ee419be9fbe4aca3ec3249650e.squirrel@webmail-b.css.fujitsu.com>
	<20090316121915.GB16897@balbir.in.ibm.com>
	<20090317124740.d8356d01.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317044016.GG16897@balbir.in.ibm.com>
	<20090317134727.62efc14e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317045850.GJ16897@balbir.in.ibm.com>
	<20090317141714.0899baec.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317055506.GM16897@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 11:25:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-17 14:17:14]:
> > > That is not true..we don't track them to default cgroup unless
> > > memory.use_hiearchy is enabled in the root cgroup. 
> > What I want to say is "the task which is not attached to user's cgroup is
> > also under defaut cgroup, so we don't need additional hook"
> > Not talking about hierarchy.
> >
> 
> Since all the user pages are tracked in one or the other cgroup, the
> total accounting is equal to total_lru_pages across all zones/nodes.
> Your suggestion boils down to if total_lru_pages reaches a threshold,
> do soft limit reclaim, instead of doing reclaim when there is
> contention.. right?
>  
Yes.


> > It's not necessary. for example, reading vmstat doesn't need global lock.
> >
> 
> It uses atomic values for accounting. 
> 
Ah, my point is that "when it comes to usage of global LRU,
accounting pages is already done somewhere. we can reuse it."
Not means "add some new counter"

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
