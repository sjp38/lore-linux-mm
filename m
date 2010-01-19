Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA7C16001DA
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 21:38:23 -0500 (EST)
Date: Tue, 19 Jan 2010 11:34:43 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100119113443.562e38ba.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <661de9471001181749y2fe22a15j1c01c94aa1838e99@mail.gmail.com>
References: <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107083440.GS3059@balbir.in.ibm.com>
	<20100107174814.ad6820db.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107180800.7b85ed10.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107092736.GW3059@balbir.in.ibm.com>
	<20100108084727.429c40fc.kamezawa.hiroyu@jp.fujitsu.com>
	<661de9471001171130p2b0ac061he6f3dab9ef46fd06@mail.gmail.com>
	<20100118094920.151e1370.nishimura@mxp.nes.nec.co.jp>
	<4B541B44.3090407@linux.vnet.ibm.com>
	<20100119102208.59a16397.nishimura@mxp.nes.nec.co.jp>
	<661de9471001181749y2fe22a15j1c01c94aa1838e99@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Jan 2010 07:19:42 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> On Tue, Jan 19, 2010 at 6:52 AM, Daisuke Nishimura
> <nishimura@mxp.nes.nec.co.jp> wrote:
> [snip]
> >> Correct, file cache is almost always considered shared, so it has
> >>
> >> 1. non-private or shared usage of 10MB
> >> 2. 10 MB of file cache
> >>
> >> > I don't think "non private usage" is appropriate to this value.
> >> > Why don't you just show "sum_of_each_process_rss" ? I think it would be easier
> >> > to understand for users.
> >>
> >> Here is my concern
> >>
> >> 1. The gap between looking at memcg stat and sum of all RSS is way
> >> higher in user space
> >> 2. Summing up all rss without walking the tasks atomically can and
> >> will lead to consistency issues. Data can be stale as long as it
> >> represents a consistent snapshot of data
> >>
> >> We need to differentiate between
> >>
> >> 1. Data snapshot (taken at a time, but valid at that point)
> >> 2. Data taken from different sources that does not form a uniform
> >> snapshot, because the timestamping of the each of the collected data
> >> items is different
> >>
> > Hmm, I'm sorry I can't understand why you need "difference".
> > IOW, what can users or middlewares know by the value in the above case
> > (0MB in 01 and 10MB in 02)? I've read this thread, but I can't understande about
> > this point... Why can this value mean some of the groups are "heavy" ?
> >
> 
> Consider a default cgroup that is not root and assume all applications
> move there initially. Now with a lot of shared memory,
> the default cgroup will be the first one to page in a lot of the
> memory and its usage will be very high. Without the concept of
> showing how much is non-private, how does one decide if the default
> cgroup is using a lot of memory or sharing it? How
> do we decide on limits of a cgroup without knowing its actual usage -
> PSS equivalent for a region of memory for a task.
> 
As for limit, I think we should decide it based on the actual usage because
we account and limit the accual usage. Why we should take account of the sum of rss ?
I agree that we'd better not to ignore the sum of rss completely, but could you show me
how the value 0MB/10MB can be used to caluculate the limit in 01/02 in detail ?
I wouldn't argue against you if I could understand the value would be useful,
but I can't understand how the value can be used, so I'm asking :)

Thanks
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
