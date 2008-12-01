Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id mB16f28c100368
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 17:41:03 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB16OZ3b248572
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 17:24:42 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB16OYIj004175
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 17:24:35 +1100
Date: Mon, 1 Dec 2008 11:54:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/3] cgroup id and scanning without cgroup_lock
Message-ID: <20081201062429.GD28478@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-01 14:59:07]:

> This is a series of patches againse mmotm-Nov29
> (passed easy test)
> 
> Now, memcg supports hierarhcy. But walking cgroup tree in intellegent way
> with lock/unlock cgroup_mutex seems to have troubles rather than expected.
> And, I want to reduce the memory usage of swap_cgroup, which uses array of
> pointers.
> 
> This patch series provides
> 	- cgroup_id per cgroup object.
> 	- lookup struct cgroup by cgroup_id
> 	- scan all cgroup under tree by cgroup_id. without mutex.
> 	- css_tryget() function.
> 	- fixes semantics of notify_on_release. (I think this is valid fix.)
> 
> Many changes since v1. (But I wonder some more work may be neeeded.)
> 
> BTW, I know there are some amount of patches against memcg are posted recently.
> If necessary, I'll prepare Weekly-update queue again (Wednesday) and
> picks all patches to linux-mm in my queue.
>

Thanks for the offer, I've just come back from foss.in. I need to look
athe locking issue with cgroup_lock() reported and also review/test
the other patches. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
