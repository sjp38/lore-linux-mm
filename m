Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC1B6200FA
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 23:18:01 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o733KRoM018565
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 21:20:27 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o733MLmL151102
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 21:22:21 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o733MKnF005949
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 21:22:20 -0600
Date: Tue, 3 Aug 2010 08:52:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mm 1/5] quick lookup memcg by ID
Message-ID: <20100803032216.GC3863@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100802191304.8e520808.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100802191304.8e520808.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:13:04]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, memory cgroup has an ID per cgroup and make use of it at
>  - hierarchy walk,
>  - swap recording.
> 
> This patch is for making more use of it. The final purpose is
> to replace page_cgroup->mem_cgroup's pointer to an unsigned short.
> 
> This patch caches a pointer of memcg in an array. By this, we
> don't have to call css_lookup() which requires radix-hash walk.
> This saves some amount of memory footprint at lookup memcg via id.
>

It is a memory versus speed tradeoff, but if the number of created
cgroups is low, it might not be all that slow, besides we do that for
swap_cgroup anyway - no?
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
