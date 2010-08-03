Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2BDEA600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 22:32:53 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o732YvNp017965
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 20:34:57 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o732aqfK145224
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 20:36:52 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o732apTP010515
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 20:36:52 -0600
Date: Tue, 3 Aug 2010 08:06:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mm 0/5] towards I/O aware memory cgroup v3.
Message-ID: <20100803023648.GB3863@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:11:13]:

> 
> This is v3. removed terrble garbages from v2 and tested.(no big changes)
> 
> Now, it's merge-window and I'll have to maintain this in my box for a while.
> I'll continue to update this. Maybe we can make new progress after LinuxCon.
> (And I'll be busy for a while.)
>


I was catching up with my inbox, did not realize you had moved onto v3
and hence reviewed v1 first.
 
> This set has 2+1 purposes.
>  1. re-desgin struct page_cgroup and makes room for blocckio-cgroup ID.
>  2. implement quick updating method for memcg's file stat.
>  3. optionally? use spin_lock instead of bit_spinlock.
> 
> Plans after this.
> 
>  1. check influence of Mel's new writeback method.
>     I think we'll see OOM easier. IIUC, memory cgroup needs a thread like kswapd
>     to do background writeback or low-high watermark.
>     (By this, we can control priority of background writeout thread priority
>      by CFS. This is very good.)

Agreed, background watermark based reclaim is something we should look
at.

> 
>  2. implementing dirty_ratio.
>     Now, Greg Thelen is working on. One of biggest problems of previous trial was
>     update cost of status. I think this patch set can reduce it.

That is good news

> 
>  3. record blockio cgroup's ID.
>     Ikeda posted one. IIUC, it requires some consideration on (swapin)readahead
>     for assigning IDs. But it seemed to be good in general.
> 
> Importance is in this order in my mind. But all aboves can be done in parallel.
> 
> Beyond that, some guys has problem with file-cache-control. If it need to use
> account migration, we have to take care of races.
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
