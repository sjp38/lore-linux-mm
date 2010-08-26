Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 540676B02AB
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 20:18:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7Q0IhJT006638
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Aug 2010 09:18:44 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B9F4845DE51
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 09:18:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 96B0845DE4F
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 09:18:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EBD1E38002
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 09:18:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B5D4E38001
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 09:18:43 +0900 (JST)
Date: Thu, 26 Aug 2010 09:13:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] cgroup: do ID allocation under css allocator.
Message-Id: <20100826091346.88eb3ecc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100825141500.GA32680@balbir.in.ibm.com>
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
	<20100825170640.5f365629.kamezawa.hiroyu@jp.fujitsu.com>
	<20100825141500.GA32680@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010 19:45:00 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-25 17:06:40]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, css'id is allocated after ->create() is called. But to make use of ID
> > in ->create(), it should be available before ->create().
> > 
> > In another thinking, considering the ID is tightly coupled with "css",
> > it should be allocated when "css" is allocated.
> > This patch moves alloc_css_id() to css allocation routine. Now, only 2 subsys,
> > memory and blkio are useing ID. (To support complicated hierarchy walk.)
>                        ^^^^ typo
> > 
> > ID will be used in mem cgroup's ->create(), later.
> > 
> > Note:
> > If someone changes rules of css allocation, ID allocation should be moved too.
> > 
> 
> What rules? could you please elaborate?
> 
See Paul Menage's mail. He said "allocating css object under kernel/cgroup.c
will make kernel/cgroup.c cleaner." But it seems too big for my purpose.

> Seems cleaner, may be we need to update cgroups.txt?

Hmm. will look into.

Thanks,
-Kame

> 
> -- 
> 	Three Cheers,
> 	Balbir
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
