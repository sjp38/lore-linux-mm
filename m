Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0746B0047
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 13:17:50 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8DHBGm7009854
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 13:11:16 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8DHHmYT269362
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 13:17:48 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8DHHl3s011886
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 14:17:48 -0300
Date: Mon, 13 Sep 2010 22:47:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix race in file_mapped accouting flag
 management
Message-ID: <20100913171741.GM17950@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100913160822.0c2cd732.kamezawa.hiroyu@jp.fujitsu.com>
 <20100913084741.GD17950@balbir.in.ibm.com>
 <AANLkTimsUQuEeS2QvSwY_WhnQY7n=D73fNmOoqgrTqbZ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <AANLkTimsUQuEeS2QvSwY_WhnQY7n=D73fNmOoqgrTqbZ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

* Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com> [2010-09-14 00:28:30]:

> > In the situation above who has the PTE lock? Are we not synchronized
> > via the PTE lock such that add rmap and rm rmap, will not happen
> > simultaneously?
> >
> In this case, a process for map and one for unmap can be different.
> 
> Assume process A maps a file cache and process B not.
> While process A unmap a file, process B can map it.
> pte lock is no help.
>

Correct, so while the accounting is correct, the flag can definitely
go wrong. I misread your race description earlier.

Thanks! 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
