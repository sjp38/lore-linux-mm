Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L5eKGl023140
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 14:40:21 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B99182AC026
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 14:40:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 839EC12C046
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 14:40:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D6C01DB803B
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 14:40:20 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A2181DB8037
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 14:40:20 +0900 (JST)
Date: Tue, 21 Oct 2008 14:39:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
Message-Id: <20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48FD6901.6050301@linux.vnet.ibm.com>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD6901.6050301@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 11:00:41 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 1. It's harmful to increase size of *generic* res_counter. So, modifing
> >    res_counter only for us is not a choice.
> > 2. Operation should be done under a lock. We have to do 
> >    -page + swap in atomic, at least.
> > 3. We want to pack all member into a cache-line, multiple res_counter
> >    is no good.
> > 4. I hate res_counter ;)
> > 
> 
> What do you hate about it? I'll review the patchset in detail (I am currently
> unwell, but I'll definitely take a look later).
> 
Just because I feel this kind of *generic* counter can be an obstacle to
do aggressive special optimization for some resource. But I don't want to
argue this now. 

I'll rewrite and avoid to add new mem_counter. (and use 2 res_counters.)

Core logic will not be changed very much but....
Anyway, I'll go to the way which doesn't bother anyone.

BTW, "allocate all page_cgroup at boot" patch goes to Linus' git. Wow.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
