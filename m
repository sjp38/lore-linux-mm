Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1016B01F4
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 10:15:07 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7PED8ZW013425
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 08:13:08 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o7PEF6BU230558
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 08:15:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7PEF5On030828
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 08:15:05 -0600
Date: Wed, 25 Aug 2010 19:45:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/5] cgroup: do ID allocation under css allocator.
Message-ID: <20100825141500.GA32680@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
 <20100825170640.5f365629.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100825170640.5f365629.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-25 17:06:40]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, css'id is allocated after ->create() is called. But to make use of ID
> in ->create(), it should be available before ->create().
> 
> In another thinking, considering the ID is tightly coupled with "css",
> it should be allocated when "css" is allocated.
> This patch moves alloc_css_id() to css allocation routine. Now, only 2 subsys,
> memory and blkio are useing ID. (To support complicated hierarchy walk.)
                       ^^^^ typo
> 
> ID will be used in mem cgroup's ->create(), later.
> 
> Note:
> If someone changes rules of css allocation, ID allocation should be moved too.
> 

What rules? could you please elaborate?

Seems cleaner, may be we need to update cgroups.txt?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
