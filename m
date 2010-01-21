Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2E4216B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 20:34:17 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0L1YEDF000601
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 21 Jan 2010 10:34:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CAA845DE4F
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:34:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3240C45DE50
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:34:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F0511DB8040
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:34:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CE0B0E08005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:34:11 +0900 (JST)
Date: Thu, 21 Jan 2010 10:30:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100121103047.2667b864.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100121100416.88074a46.nishimura@mxp.nes.nec.co.jp>
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
	<20100119113443.562e38ba.nishimura@mxp.nes.nec.co.jp>
	<4B552C89.8000004@linux.vnet.ibm.com>
	<20100120130902.865d8269.nishimura@mxp.nes.nec.co.jp>
	<4B56BC09.2090508@linux.vnet.ibm.com>
	<20100121100416.88074a46.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 2010 10:04:16 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Anyway, I wouldn't say any more about the usefullness of "shared_usage_in_bytes".
> 
> But if you dare to add this interface to kernel, please and please write the documentation
> that it can be used to roughly estimate a sum of i) and ii), not sum of i) and iii), and
> can be used to decide the weight of the group only when few pages are shared between groups.
> So that users doesn't misunderstand nor misuse the interface.
> 
> And I think you should answer what Kamezawa-san pointed in http://lkml.org/lkml/2010/1/17/186.
> 
> 
I wouldn't like to say anything other than 'please add stat to global VM before
memcg if it's really important" because it seems I couldn't persuade him, he can't
do so me. I myself never think sum of rss is important.

An additonal craim I can easily think of is fork()->exit().
Assume there is a program with 1GB RSS and which invokes a helper program by
fork()->exec(). This is an usual situation. Then, sum of RSS can easily
jump up/down 1GB.

Even if getting data in atomic way, the data itself can be corrupted very
easily and the users should remove noises by themselves. So, there is no much
difference to calculate RSS in user land or kernel. The users has to measure
the status and estimate the stable value in statical technique.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
