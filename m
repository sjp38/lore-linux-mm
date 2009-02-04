Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1E65E6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 01:53:21 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n146rIGh022632
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Feb 2009 15:53:18 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EBB4845DE53
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:53:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C95C545DE55
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:53:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 869581DB8040
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:53:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 202081DB805E
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 15:53:14 +0900 (JST)
Date: Wed, 4 Feb 2009 15:52:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
Message-Id: <20090204155203.3733dc8e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49893A5A.7000506@cn.fujitsu.com>
References: <20090203172135.GF918@balbir.in.ibm.com>
	<4988E727.8030807@cn.fujitsu.com>
	<20090204033750.GB4456@balbir.in.ibm.com>
	<20090204142455.83c38ad6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090204064249.GC4456@balbir.in.ibm.com>
	<49893A5A.7000506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 04 Feb 2009 14:48:58 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> >> BTW, I wonder can't we show the path of mount point ?
> >> /group_A/01 is /cgroup/group_A/01 and /group_A/ is /cgroup/group_A/ on this system.
> >> Very difficult ?
> >>
> > 
> > No, it is not very difficult, we just need to append the mount point.
> > The reason for not doing it is consistency with output of
> > /proc/<pid>/cgroup and other places where cgroup_path prints the path
> > relative to the mount point. Since we are talking about memory, the
> > administrator should know where it is mounted. Do you strongly feel
> > the need to add mount point? My concern is consistency with other
> > cgroup output (look at /proc/sched_debug) for example.
> > 
> 
> Another reason to not do so is, we can mount a specific hierarchy to
> multiple mount points.
> 	# mount -t cgroup -o memory /mnt
> 	# mount -t cgroup -o memory /cgroup
> 	# mkdir /mnt/0
> Now, /mnt/0 is the same with /cgroup/0.
> 
Thank you for clarification. Current logic seems right.

Thanks.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
