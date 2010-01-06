Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4BF5C6B0047
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 02:15:25 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o067FMJR021826
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 6 Jan 2010 16:15:22 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 302EA45DE51
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 16:15:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DA6D45DE4F
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 16:15:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E15901DB8040
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 16:15:21 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 95FBA1DB8037
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 16:15:21 +0900 (JST)
Date: Wed, 6 Jan 2010 16:12:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100106161211.5a7b600f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100106070150.GL3059@balbir.in.ibm.com>
References: <20091229182743.GB12533@balbir.in.ibm.com>
	<20100104085108.eaa9c867.kamezawa.hiroyu@jp.fujitsu.com>
	<20100104000752.GC16187@balbir.in.ibm.com>
	<20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
	<20100104005030.GG16187@balbir.in.ibm.com>
	<20100106130258.a918e047.kamezawa.hiroyu@jp.fujitsu.com>
	<20100106070150.GL3059@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jan 2010 12:31:50 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > No. If it takes long time, locking fork()/exit() for such long time is the bigger
> > issue.
> > I recommend you to add memacct subsystem to sum up RSS of all processes's RSS counting
> > under a cgroup.  Althoght it may add huge costs in page fault path but implementation
> > will be very simple and will not hurt realtime ops.
> > There will be no terrible race, I guess.
> >
> 
> But others hold that lock as well, simple thing like listing tasks and
> moving tasks, etc. I expect the usage of shared to be in the same
> range.
> 

And piles up costs ? I think cgroup guys should pay attention to fork/exit
costs more. Now, it gets slower and slower.
In that point, I never like migrate-at-task-move work in cpuset and memcg.

My 1st objection to this patch is this "shared" doesn't mean "shared between
cgroup" but means "shared between processes".
I think it's of no use and no help to users.

And implementation is 2nd thing.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
