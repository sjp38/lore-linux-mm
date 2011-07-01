Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3426B004A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 21:37:20 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 55E293EE0C0
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:37:16 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 30FCE45DE81
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:37:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1708D45DE7A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:37:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 066011DB803F
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:37:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC17A1DB8038
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:37:15 +0900 (JST)
Date: Fri, 1 Jul 2011 10:30:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v2
Message-Id: <20110701103007.8110f130.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110701101624.a10b7e34.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110630130134.63a1dd37.akpm@linux-foundation.org>
	<20110701085013.4e8cbb02.kamezawa.hiroyu@jp.fujitsu.com>
	<20110701092059.be4400f7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110630180653.1df10f38.akpm@linux-foundation.org>
	<20110701101624.a10b7e34.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, 1 Jul 2011 10:16:24 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 30 Jun 2011 18:06:53 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Fri, 1 Jul 2011 09:20:59 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Fri, 1 Jul 2011 08:50:13 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Thu, 30 Jun 2011 13:01:34 -0700
> > > > Andrew Morton <akpm@linux-foundation.org> wrote:
> > > 
> > > > Ok, I'll check it. Maybe I miss !CONFIG_SWAP...
> > > > 
> > > 
> > > v4 here. Thank you for pointing out. I could think of several ways but
> > > maybe this one is good because using vm_swappines with !CONFIG_SWAP seems
> > > to be a bug.
> > 
> > No, it isn't a bug - swappiness also controls the kernel's eagerness to
> > unmap and reclaim mmapped pagecache.
> > 
> 
> Oh, really ? I didn't understand that.
> 
Hmm, anyway, this new version of fix seems better.
==
