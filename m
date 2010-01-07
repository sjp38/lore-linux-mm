Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AA66C6B0047
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 04:11:18 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o079BGJ2020295
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Jan 2010 18:11:16 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B70A045DE51
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 18:11:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9438245DE52
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 18:11:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F85D1DB805B
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 18:11:15 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D417A1DB8043
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 18:11:14 +0900 (JST)
Date: Thu, 7 Jan 2010 18:08:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100107180800.7b85ed10.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100107174814.ad6820db.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091229182743.GB12533@balbir.in.ibm.com>
	<20100104085108.eaa9c867.kamezawa.hiroyu@jp.fujitsu.com>
	<20100104000752.GC16187@balbir.in.ibm.com>
	<20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
	<20100104005030.GG16187@balbir.in.ibm.com>
	<20100106130258.a918e047.kamezawa.hiroyu@jp.fujitsu.com>
	<20100106070150.GL3059@balbir.in.ibm.com>
	<20100106161211.5a7b600f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107071554.GO3059@balbir.in.ibm.com>
	<20100107163610.aaf831e6.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107083440.GS3059@balbir.in.ibm.com>
	<20100107174814.ad6820db.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 17:48:14 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > "How pages are shared" doesn't show good hints. I don't hear such parameter
> > > is used in production's resource monitoring software.
> > > 
> > 
> > You mean "How many pages are shared" are not good hints, please see my
> > justification above. With Virtualization (look at KSM for example),
> > shared pages are going to be increasingly important part of the
> > accounting.
> > 
> 
> Considering KSM, your cuounting style is tooo bad.
> 
> You should add 
> 
>  - MEM_CGROUP_STAT_SHARED_BY_KSM
>  - MEM_CGROUP_STAT_FOR_TMPFS/SYSV_IPC_SHMEM
> 
> counters to memcg rather than scanning. I can help tests.
> 
> I have no objections to have above 2 counters. It's informative.
> 
> But, memory reclaim can page-out pages even if pages are shared.
> So, "how heavy memcg is" is an independent problem from above coutners.
> 

In other words, above counters can show
"What role the memcg play in the system" to some extent.

But I don't express it as "heavy" ....."importance or influence of cgroup" ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
