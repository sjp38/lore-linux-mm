Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7B1ED6B006A
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 19:25:34 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I0PWoC006843
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 18 Jan 2010 09:25:32 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E9D2D45DE50
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 09:25:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BBDF545DE4E
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 09:25:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56D15E38003
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 09:25:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 03959E38002
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 09:25:31 +0900 (JST)
Date: Mon, 18 Jan 2010 09:22:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100118092217.98885b43.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100118090549.6d3af93b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
	<20100106070150.GL3059@balbir.in.ibm.com>
	<20100106161211.5a7b600f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107071554.GO3059@balbir.in.ibm.com>
	<20100107163610.aaf831e6.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107083440.GS3059@balbir.in.ibm.com>
	<20100107174814.ad6820db.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107180800.7b85ed10.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107092736.GW3059@balbir.in.ibm.com>
	<20100108084727.429c40fc.kamezawa.hiroyu@jp.fujitsu.com>
	<661de9471001171130p2b0ac061he6f3dab9ef46fd06@mail.gmail.com>
	<20100118090549.6d3af93b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jan 2010 09:05:49 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > 
> > Kamezawa-San,
> > 
> > I implemented the same in user space and I get really bad results, here is why
> > 
> > 1. I need to hold and walk the tasks list in cgroups and extract RSS
> > through /proc (results in worse hold times for the fork() scenario you
> > menioned)
> > 2. The data is highly inconsistent due to the higher margin of error
> > in accumulating data which is changing as we run. By the time we total
> > and look at the memcg data, the data is stale
> > 
> > Would you be OK with the patch, if I renamed "shared_usage_in_bytes"
> > to "non_private_usage_in_bytes"?
> > 
> > Given that the stat is user initiated, I don't see your concern w.r.t.
> > overhead. Many subsystems like KSM do pay the overhead cost if the
> > user really wants the feature or the data. I would be really
> > interested in other opinions as well (if people do feel strongly
> > against or for the feature)
> > 
> 
> Please add that featuter to global VM before memcg.
> If VM guyes admits its good, I have no objections more.
> 

I don't want to say any more but...one point.

If the status of memory changes so frequently as the user land check program
can't calculate stable data, what the management daemon can react agasinst
it...the stale data ? So, I think it's nonsense anyway.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
