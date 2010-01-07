Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 61B686B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 18:50:45 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o07NogJw018183
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 8 Jan 2010 08:50:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B7A1245DE52
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 08:50:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 88B6B45DE4E
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 08:50:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B3ED1DB803C
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 08:50:42 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FF501DB8043
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 08:50:42 +0900 (JST)
Date: Fri, 8 Jan 2010 08:47:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100108084727.429c40fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100107092736.GW3059@balbir.in.ibm.com>
References: <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
	<20100104005030.GG16187@balbir.in.ibm.com>
	<20100106130258.a918e047.kamezawa.hiroyu@jp.fujitsu.com>
	<20100106070150.GL3059@balbir.in.ibm.com>
	<20100106161211.5a7b600f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107071554.GO3059@balbir.in.ibm.com>
	<20100107163610.aaf831e6.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107083440.GS3059@balbir.in.ibm.com>
	<20100107174814.ad6820db.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107180800.7b85ed10.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107092736.GW3059@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 14:57:36 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-07 18:08:00]:
> 
> > On Thu, 7 Jan 2010 17:48:14 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > "How pages are shared" doesn't show good hints. I don't hear such parameter
> > > > > is used in production's resource monitoring software.
> > > > > 
> > > > 
> > > > You mean "How many pages are shared" are not good hints, please see my
> > > > justification above. With Virtualization (look at KSM for example),
> > > > shared pages are going to be increasingly important part of the
> > > > accounting.
> > > > 
> > > 
> > > Considering KSM, your cuounting style is tooo bad.
> > > 
> > > You should add 
> > > 
> > >  - MEM_CGROUP_STAT_SHARED_BY_KSM
> > >  - MEM_CGROUP_STAT_FOR_TMPFS/SYSV_IPC_SHMEM
> > > 
> 
> No.. I am just talking about shared memory being important and shared
> accounting being useful, no counters for KSM in particular (in the
> memcg context).
> 
Think so ? The number of memcg-private pages is in interest in my point of view.

Anyway, I don't change my opinion as "sum of rss" is not necessary to be calculated
in the kernel.
If you want to provide that in memcg, please add it to global VM as /proc/meminfo.

IIUC, KSM/SHMEM has some official method in global VM.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
