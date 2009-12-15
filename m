Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 25B656B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 00:12:17 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF5CELZ030434
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Dec 2009 14:12:14 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2822B45DE4E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:12:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EFE2345DE4D
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:12:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D9F9C1DB803F
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:12:13 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 87BB31DB8040
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:12:13 +0900 (JST)
Date: Tue, 15 Dec 2009 14:09:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with
 nodemask v4.2
Message-Id: <20091215140913.e28f7674.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0912142054520.436@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com>
	<20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com>
	<20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com>
	<20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911171609370.12532@chino.kir.corp.google.com>
	<20091118095824.076c211f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911171725050.13760@chino.kir.corp.google.com>
	<20091214171632.0b34d833.akpm@linux-foundation.org>
	<20091215103202.eacfd64e.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0912142025090.29243@chino.kir.corp.google.com>
	<20091215134327.6c46b586.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0912142054520.436@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Dec 2009 20:57:53 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 15 Dec 2009, KAMEZAWA Hiroyuki wrote:
> 
> > > That's not at all what I said.  I said using total_vm as a baseline allows 
> > > users to define when a process is to be considered "rogue," that is, using 
> > > more memory than expected.  Using rss would be inappropriate since it is 
> > > highly dynamic and depends on the state of the VM at the time of oom, 
> > > which userspace cannot possibly keep updated.
> > > 
> > > You consistently ignore that point: the power of /proc/pid/oom_adj to 
> > > influence when a process, such as a memory leaker, is to be considered as 
> > > a high priority for an oom kill.  It has absolutely nothing to do with 
> > > fake NUMA, cpusets, or memcg.
> > > 
> > You also ignore that it's not sane to use oom kill for resource control ;)
> > 
> 
> Please read my email.  Did I say anything about resource control AT ALL?  
> I said /proc/pid/oom_adj currently allows userspace to define when a task 
> is "rogue," meaning its consuming much more memory than expected.  Those 
> memory leakers should always be the optimal result for the oom killer to 
> kill.  Using rss as the baseline would not allow userspace to effectively 
> do the same thing since it's dynamic and depends on the state of the VM at 
> the time of oom which is probably not reflected in the /proc/pid/oom_adj 
> values for all tasks.  It has absolutely nothing to do with resource 
> control, so please address this very trivial issue without going off on 
> tangents.  Thanks.

What I can't undestand is the technique to know whether a (unknown) process is
leaking memory or not by checking vm_size.
And, why don't you use overcommit_memory when you can depends on vm_size ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
