Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BE4E66B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 04:31:16 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n548UaSS009959
	for <linux-mm@kvack.org>; Thu, 4 Jun 2009 02:30:36 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n548VEw8132788
	for <linux-mm@kvack.org>; Thu, 4 Jun 2009 02:31:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n548VE9S022386
	for <linux-mm@kvack.org>; Thu, 4 Jun 2009 02:31:14 -0600
Date: Thu, 4 Jun 2009 16:31:10 +0800
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] remove memory.limit v.s. memsw.limit comparison.
Message-ID: <20090604083110.GD7504@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090604141043.9a1064fd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090604141043.9a1064fd.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-04 14:10:43]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Removes memory.limit < memsw.limit at setting limit check completely.
> 
> The limitation "memory.limit <= memsw.limit" was added just because
> it seems sane ...if memory.limit > memsw.limit, only memsw.limit works.
> 
> But To implement this limitation, we needed to use private mutex and make
> the code a bit complated.
> As Nishimura pointed out, in real world, there are people who only want
> to use memsw.limit.
> 
> Then, this patch removes the check. user-land library or middleware can check
> this in userland easily if this really concerns.
> 
> And this is a good change to charge-and-reclaim.
> 
> Now, memory.limit is always checked before memsw.limit
> and it may do swap-out. But, if memory.limit == memsw.limit, swap-out is
> finally no help and hits memsw.limit again. So, let's allow the condition
> memory.limit > memsw.limit. Then we can skip unnecesary swap-out.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

We can't change behaviour this way without breaking userspace scripts,
API and code. What does it mean for people already using these
features? Does it break their workflow?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
