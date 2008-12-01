Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB17qu2i001828
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Dec 2008 16:52:56 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4043445DE56
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 16:52:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A2CC45DE50
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 16:52:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D9FF41DB8040
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 16:52:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AB721DB803B
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 16:52:55 +0900 (JST)
Date: Mon, 1 Dec 2008 16:52:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] cgroup id and scanning without cgroup_lock
Message-Id: <20081201165207.0db76b1f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081201062429.GD28478@balbir.in.ibm.com>
References: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>
	<20081201062429.GD28478@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008 11:54:29 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-01 14:59:07]:
> 
> > This is a series of patches againse mmotm-Nov29
> > (passed easy test)
> > 
> > Now, memcg supports hierarhcy. But walking cgroup tree in intellegent way
> > with lock/unlock cgroup_mutex seems to have troubles rather than expected.
> > And, I want to reduce the memory usage of swap_cgroup, which uses array of
> > pointers.
> > 
> > This patch series provides
> > 	- cgroup_id per cgroup object.
> > 	- lookup struct cgroup by cgroup_id
> > 	- scan all cgroup under tree by cgroup_id. without mutex.
> > 	- css_tryget() function.
> > 	- fixes semantics of notify_on_release. (I think this is valid fix.)
> > 
> > Many changes since v1. (But I wonder some more work may be neeeded.)
> > 
> > BTW, I know there are some amount of patches against memcg are posted recently.
> > If necessary, I'll prepare Weekly-update queue again (Wednesday) and
> > picks all patches to linux-mm in my queue.
> >
> 
> Thanks for the offer, I've just come back from foss.in. I need to look
> athe locking issue with cgroup_lock() reported and also review/test
> the other patches. 
> 
Hmm, after reading mailing list again, it seems it's better to do some serialization.
I'll pick up some and post a queue tomorrow.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
