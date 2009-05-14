Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 42AE26B005D
	for <linux-mm@kvack.org>; Thu, 14 May 2009 19:48:05 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4ENmmdY009177
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 15 May 2009 08:48:48 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AD7245DE4C
	for <linux-mm@kvack.org>; Fri, 15 May 2009 08:48:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1986F45DE53
	for <linux-mm@kvack.org>; Fri, 15 May 2009 08:48:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D748FE08001
	for <linux-mm@kvack.org>; Fri, 15 May 2009 08:48:47 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 739231DB803C
	for <linux-mm@kvack.org>; Fri, 15 May 2009 08:48:47 +0900 (JST)
Date: Fri, 15 May 2009 08:47:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] fix stale swap cache account leak  in memcg v7
Message-Id: <20090515084716.544930d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090513093127.4dadac97.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512095158.GB6351@balbir.in.ibm.com>
	<20090513093127.4dadac97.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009 09:31:27 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 12 May 2009 15:21:58 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > > The patch set includes followng
> > >  [1/3] add mem_cgroup_is_activated() function. which tell us memcg is _really_ used.
> > >  [2/3] fix swap cache handling race by avoidng readahead.
> > >  [3/3] fix swap cache handling race by check swapcount again.
> > > 
> > > Result is good under my test.
> > 
> > What was the result (performance data impact) of disabling swap
> > readahead? Otherwise, this looks the most reasonable set of patches
> > for this problem.
> > 
> I'll measure some and report it in the next post.
> 
I confirmed there are cases which swapin readahead works very well....

Nishimura-san, could you post a patch for fixing leak at writeback ? as [3/3]
I'd like to fix readahead case...with some large patch.

Hm, I didn't think this problem took 2 months to be fixed ;(

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
