Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C7EED6B004A
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 02:30:26 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB17UNqY004002
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Dec 2010 16:30:24 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D39E45DE62
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 16:30:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41E4D45DE59
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 16:30:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 308B0E18006
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 16:30:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E57C01DB803B
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 16:30:22 +0900 (JST)
Date: Wed, 1 Dec 2010 16:24:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages
Message-Id: <20101201162444.5c7b1616.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101201064043.GO2746@balbir.in.ibm.com>
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
	<20101130101602.17475.32611.stgit@localhost6.localdomain6>
	<20101201103254.b823eae0.kamezawa.hiroyu@jp.fujitsu.com>
	<20101201051816.GI2746@balbir.in.ibm.com>
	<20101201052259.GN2746@balbir.in.ibm.com>
	<20101201143550.0b652916.kamezawa.hiroyu@jp.fujitsu.com>
	<20101201064043.GO2746@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Dec 2010 12:10:43 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > That's a point. Then, why the guest has to do _extra_ work for host even when
> > the host says nothing ? I think trigger this by guests themselves is not very good.
> 
> I've mentioned it before, the guest keeping free memory without a
> large performance hit, helps, the balloon driver is able to quickly
> retrieve this memory if required or the guest can use this memory for
> some other application/task. 


> The cached data is mostly already present in the host page cache.

Why ? Are there parameters/stats which shows this is _true_ ? How we can
guarantee/show it to users ?
Please add an interface to show "shared rate between guest/host" If not,
any admin will not turn this on because "file cache status on host" is a
black box for guest admins. I think this patch skips something important steps.

2nd point is maybe for reducing total host memory usage and for increasing
the number of guests on a host. For that, this feature is useful only when all guests
on a host are friendly and devoted to the health of host memory management because
all setting must be done in the guest. This can be passed as even by qemu's command line
argument. And _no_ benefit for the guests who reduce it's resource to help
host management because there is no guarantee dropped caches are on host memory.


So, for both claim, I want to see an interface to show the number of shared pages
between hosts and guests rather than imagine it.

BTW, I don't like this kind of "please give us your victim, please please please"
logic. The host should be able to "steal" what it wants in force.
Then, I think there should be no On/Off visible interfaces. The vm firmware
should tell to turn on this if administrator of the host wants.

BTW2, please test with some other benchmarks (which read file caches.)
I don't think kernel make is good test for this.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
